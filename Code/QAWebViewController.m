//
//  QAWebViewController.m
//  Q&A
//
//  Created by Boris Bügling on 19/03/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "QAWebViewController.h"

@interface QAWebViewController ()

@property (nonatomic) UIWebView* webView;

@end

#pragma mark -

@implementation QAWebViewController

-(void)setURL:(NSURL *)URL {
    _URL = URL;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:URL]];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.webView];
    
    [self setURL:self.URL];
}

@end
