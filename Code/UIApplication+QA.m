//
//  UIApplication+QA.m
//  Q&A
//
//  Created by Boris Bügling on 19/03/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "QAAppDelegate.h"
#import "UIApplication+QA.h"

@implementation UIApplication (QA)

-(CDAClient *)client {
    return ((QAAppDelegate*)self.delegate).client;
}

-(void)setClient:(CDAClient *)client {
    [(QAAppDelegate*)self.delegate setClient:client];
}

@end
