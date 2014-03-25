//
//  QAInfoViewController.m
//  Q&A
//
//  Created by Boris Bügling on 25/03/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "QAInfoViewController.h"

@interface QAInfoViewController () <UITextViewDelegate>

@end

#pragma mark -

@implementation QAInfoViewController

-(id)init {
    self = [super init];
    if (self) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped)];
        
        self.title = NSLocalizedString(@"Credits", nil);
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableAttributedString* infoText = [[NSMutableAttributedString alloc] initWithString:@"Contentful is a content management platform for web applications, mobile apps and connected devices. It allows you to create, edit & manage content in the cloud and publish it anywhere via powerful API. Contentful offers tools for managing editorial teams and enabling cooperation between organisations.\n\nTo learn more about how Contentful can help you scale your publishing efforts, please visit our website at www.contentful.com or email us at sales@contentful.com."];
    
    NSRange someRange = [infoText.string rangeOfString:@"www.contentful.com"];
    [infoText addAttribute:NSLinkAttributeName value:@"http://www.contentful.com" range:someRange];
    someRange = [infoText.string rangeOfString:@"sales@contentful.com"];
    [infoText addAttribute:NSLinkAttributeName value:@"mailto:sales@contentful.com" range:someRange];
    
    UITextView* infoLabel = [[UITextView alloc] initWithFrame:self.view.bounds];
    infoLabel.attributedText = infoText;
    infoLabel.backgroundColor = [UIColor whiteColor];
    infoLabel.delegate = self;
    infoLabel.editable = NO;
    infoLabel.font = [UIFont systemFontOfSize:18.0];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:infoLabel];
}

#pragma mark - Actions

-(void)doneTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)range {
    [[UIApplication sharedApplication] openURL:URL];
    return NO;
}

@end
