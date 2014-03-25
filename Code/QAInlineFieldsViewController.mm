//
//  QAInlineFieldsViewController.m
//  Q&A
//
//  Created by Boris Bügling on 19/03/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <Bypass/Bypass.h>
#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "QAInlineFieldsViewController.h"

@interface QAInlineFieldsViewController () <UITextViewDelegate>

@property (nonatomic) CDAEntry* entry;
@property (nonatomic) UITextView* textView;

@end

#pragma mark -

@implementation QAInlineFieldsViewController

+(NSAttributedString*)attributedStringFromMarkdownString:(NSString*)markdownString {
    BPDocument* document = [[BPParser new] parse:markdownString];
    BPAttributedStringConverter* converter = [BPAttributedStringConverter new];
    NSMutableAttributedString* attributedString = [[converter convertDocument:document] mutableCopy];
    [attributedString addAttribute:NSBackgroundColorAttributeName
                             value:[UIColor whiteColor]
                             range:NSMakeRange(0, attributedString.length)];
    return attributedString;
}

+(UIImage*)imageWithImage:(UIImage *)image fitToHeight:(CGFloat)height {
    CGFloat ratio = image.size.height / height;
    CGFloat width = image.size.width / ratio;
    CGSize size = CGSizeMake(width, height);
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimage;
}

#pragma mark -

-(NSAttributedString*)convertEntryToAttributedString:(CDAEntry*)entry withOffset:(NSUInteger)offset {
    NSMutableAttributedString* entryContent = [NSMutableAttributedString new];
    NSAttributedString* padding = [[NSAttributedString alloc] initWithString:@"\n\n"];
    
    for (CDAField* field in entry.contentType.fields) {
        if ([field.identifier isEqualToString:entry.contentType.displayField]) {
            continue;
        }
        
        if (field.disabled) {
            continue;
        }
        
        id value = entry.fields[field.identifier];
        
        NSAttributedString* headlineString = [[NSAttributedString alloc] initWithString:field.name attributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:16.0], NSForegroundColorAttributeName: [UIColor darkGrayColor] }];
        
        switch (field.type) {
            case CDAFieldTypeLink: {
                if ([value isKindOfClass:[CDAEntry class]]) {
                    CDAEntry* subEntry = (CDAEntry*)value;
                    [entryContent appendAttributedString:[self convertEntryToAttributedString:subEntry withOffset:entryContent.length]];
                    continue;
                }
                
                if (![value isKindOfClass:[CDAAsset class]]) {
                    continue;
                }
                
                [entryContent appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
                NSRange range = NSMakeRange(offset + entryContent.length - 1, 1);
                
                [self insertAsset:value usingField:field atRange:range];
                break;
            }
                
            case CDAFieldTypeSymbol:
            case CDAFieldTypeText: {
                NSAttributedString* attrString = [[self class] attributedStringFromMarkdownString:value];
                [entryContent appendAttributedString:headlineString];
                [entryContent appendAttributedString:padding];
                [entryContent appendAttributedString:attrString];
                [entryContent appendAttributedString:[self horizontalLineAttributedString]];
                break;
            }
                
            case CDAFieldTypeDate:
            case CDAFieldTypeInteger:
            case CDAFieldTypeNumber:
                [entryContent appendAttributedString:headlineString];
                [entryContent appendAttributedString:[[NSAttributedString alloc] initWithString:@"\t"]];
                [entryContent appendAttributedString:[[NSAttributedString alloc] initWithString:[value description]]];
                [entryContent appendAttributedString:[self horizontalLineAttributedString]];
                break;
                
            case CDAFieldTypeArray:
                for (id item in ((NSArray*)value)) {
                    if ([item isKindOfClass:[CDAEntry class]]) {
                        CDAEntry* subEntry = (CDAEntry*)item;
                        [entryContent appendAttributedString:[self
                                                              convertEntryToAttributedString:subEntry withOffset:entryContent.length]];
                    }
                }
                break;
                
            case CDAFieldTypeBoolean:
            case CDAFieldTypeLocation:
            case CDAFieldTypeNone:
                break;
        }
    }
    
    return [entryContent copy];
}

-(void)fittingImageFromData:(NSData*)data insertIntoRange:(NSRange)range {
    UIImage* image = [UIImage imageWithData:data];
    image = [[self class] imageWithImage:image fitToHeight:250.0];
    
    NSTextAttachment* attachment = [NSTextAttachment new];
    attachment.image = image;
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableDictionary *newAttributes = [NSMutableDictionary new];
    [newAttributes setObject:attachment forKey:NSAttachmentAttributeName];
    [newAttributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    NSMutableAttributedString* imageAttachment = [NSMutableAttributedString new];
    [imageAttachment appendAttributedString:[[NSAttributedString alloc]
                                             initWithString:@"\ufffc" attributes:newAttributes]];
    [imageAttachment appendAttributedString:[self horizontalLineAttributedString]];
    
    NSMutableAttributedString* mutableText = [self.textView.attributedText mutableCopy];
    [mutableText replaceCharactersInRange:range withAttributedString:imageAttachment];
    self.textView.attributedText = mutableText;
}

-(NSAttributedString*)horizontalLineAttributedString {
    return [[NSAttributedString alloc] initWithString:@"\n\n"];
}

-(id)initWithEntry:(CDAEntry*)entry {
    self = [super init];
    if (self) {
        self.entry = entry;
        self.title = self.entry.fields[self.entry.contentType.displayField];
    }
    return self;
}

-(void)insertAsset:(CDAAsset*)asset usingField:(CDAField*)field atRange:(NSRange)range {
    [asset resolveWithSuccess:^(CDAResponse *response, CDAResource *resource) {
        CDAAsset* actualAsset = (CDAAsset*)resource;
        
        if (![actualAsset.MIMEType hasPrefix:@"image/"]) {
            return;
        }
        
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:actualAsset.URL]
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response,
                                                   NSData *data,
                                                   NSError *connectionError) {
                                   [self fittingImageFromData:data insertIntoRange:range];
                               }];
    } failure:^(CDAResponse *response, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.backgroundColor = [UIColor colorWithRed:0xDD / 255.0
                                                    green:0xDD / 255.0
                                                     blue:0xDD / 255.0
                                                    alpha:1.0];
    self.textView.delegate = self;
    self.textView.editable = NO;
    self.textView.font = [UIFont systemFontOfSize:18.0];
    self.textView.textContainerInset = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0);
    [self.view addSubview:self.textView];
    
    NSMutableAttributedString* entryContent = [NSMutableAttributedString new];
    NSAttributedString* padding = [[NSAttributedString alloc] initWithString:@"\n\n"];
    
    [entryContent appendAttributedString:[self convertEntryToAttributedString:self.entry withOffset:0]];
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString* backLink = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Einen anderen Arzt finden", nil) attributes:@{ NSLinkAttributeName: @"back://", NSParagraphStyleAttributeName: paragraphStyle }];
    
    [entryContent appendAttributedString:padding];
    [entryContent appendAttributedString:backLink];
    [entryContent appendAttributedString:padding];
    
    self.textView.attributedText = entryContent;
}

#pragma mark - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)range {
    if ([URL.scheme isEqualToString:@"back"]) {
        UIViewController* viewController = self.navigationController.viewControllers[1];
        [self.navigationController popToViewController:viewController animated:YES];
        return NO;
    }
    
    return YES;
}

@end
