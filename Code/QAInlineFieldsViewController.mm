//
//  QAInlineFieldsViewController.m
//  Q&A
//
//  Created by Boris Bügling on 19/03/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <Bypass/Bypass.h>
#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "NSTextAttachment+Field.h"
#import "QAInlineFieldsViewController.h"
#import "QAWebViewController.h"

@interface QAInlineFieldsViewController () <UITextViewDelegate>

@property (nonatomic) CDAEntry* entry;
@property (nonatomic) UIImage* playButtonImage;
@property (nonatomic) UITextView* textView;

@end

#pragma mark -

@implementation QAInlineFieldsViewController

+(NSAttributedString*)attributedStringFromMarkdownString:(NSString*)markdownString {
    BPDocument* document = [[BPParser new] parse:markdownString];
    BPAttributedStringConverter* converter = [BPAttributedStringConverter new];
    return [converter convertDocument:document];
}

+(UIImage*)imageWithImage:(UIImage *)image fitToWidth:(CGFloat)width {
    CGFloat ratio = image.size.width / width;
    CGFloat height = image.size.height / ratio;
    CGSize size = CGSizeMake(width, height);
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimage;
}

#pragma mark -

-(void)fittingImageFromData:(NSData*)data insertIntoRange:(NSRange)range {
    UIImage* image = [UIImage imageWithData:data];
    image = [[self class] imageWithImage:image fitToWidth:self.textView.frame.size.width - 40.0];
    
    NSTextAttachment* attachment = [NSTextAttachment new];
    attachment.image = image;
    
    NSAttributedString* imageAttachment = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSMutableAttributedString* mutableText = [self.textView.attributedText mutableCopy];
    [mutableText replaceCharactersInRange:range withAttributedString:imageAttachment];
    self.textView.attributedText = mutableText;
}

-(id)initWithEntry:(CDAEntry*)entry {
    self = [super init];
    if (self) {
        self.entry = entry;
        self.title = self.entry.fields[self.entry.contentType.displayField];
        
        UIImage* playButtonImage = [UIImage imageNamed:@"playbtn"];
        self.playButtonImage = [[self class] imageWithImage:playButtonImage fitToWidth:200.0];
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.delegate = self;
    self.textView.editable = NO;
    self.textView.font = [UIFont systemFontOfSize:18.0];
    self.textView.textContainerInset = UIEdgeInsetsMake(20.0, 10.0, 10.0, 20.0);
    [self.view addSubview:self.textView];
    
    NSMutableAttributedString* entryContent = [NSMutableAttributedString new];
    
    for (CDAField* field in self.entry.contentType.fields) {
        if ([field.identifier isEqualToString:self.entry.contentType.displayField]) {
            continue;
        }
        
        id value = self.entry.fields[field.identifier];
        
        switch (field.type) {
            case CDAFieldTypeLink: {
                if (![value isKindOfClass:[CDAAsset class]]) {
                    continue;
                }
                
                CDAAsset* asset = value;
                
                if ([asset.MIMEType hasPrefix:@"audio/"]) {
                    NSTextAttachment* attachment = [NSTextAttachment new];
                    attachment.field = field;
                    attachment.image = self.playButtonImage;
                    
                    NSAttributedString* attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
                    [entryContent appendAttributedString:attachmentString];
                }
                
                if ([asset.MIMEType hasPrefix:@"image/"]) {
                    [entryContent appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
                    
                    NSRange range = NSMakeRange(entryContent.length - 1, 1);
                    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:asset.URL]
                                                       queue:[NSOperationQueue mainQueue]
                                           completionHandler:^(NSURLResponse *response,
                                                               NSData *data,
                                                               NSError *connectionError) {
                                               [self fittingImageFromData:data insertIntoRange:range];
                                           }];
                }
                break;
            }
            
            case CDAFieldTypeSymbol:
            case CDAFieldTypeText: {
                NSAttributedString* attrString = [[self class] attributedStringFromMarkdownString:value];
                [entryContent appendAttributedString:attrString];
                break;
            }
                
            case CDAFieldTypeArray:
            case CDAFieldTypeBoolean:
            case CDAFieldTypeDate:
            case CDAFieldTypeInteger:
            case CDAFieldTypeLocation:
            case CDAFieldTypeNone:
            case CDAFieldTypeNumber:
                break;
        }
    }
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString* padding = [[NSAttributedString alloc] initWithString:@"\n\n\n"];
    [entryContent appendAttributedString:padding];
    
    NSAttributedString* backLink = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Go ask some more questions!", nil) attributes:@{ NSLinkAttributeName: @"back://", NSParagraphStyleAttributeName: paragraphStyle }];
    [entryContent appendAttributedString:backLink];
    
    [entryContent appendAttributedString:padding];
    
    self.textView.attributedText = entryContent;
}

#pragma mark - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    CDAAsset* asset = self.entry.fields[textAttachment.field.identifier];
    
    if ([asset.MIMEType hasPrefix:@"audio/"]) {
        QAWebViewController* webViewVC = [QAWebViewController new];
        webViewVC.title = textAttachment.field.name;
        webViewVC.URL = asset.URL;
        [self.navigationController pushViewController:webViewVC animated:YES];
    }
    
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)range {
    if ([URL.scheme isEqualToString:@"back"]) {
        UIViewController* viewController = self.navigationController.viewControllers[1];
        [self.navigationController popToViewController:viewController animated:YES];
        return NO;
    }
    
    return YES;
}

@end
