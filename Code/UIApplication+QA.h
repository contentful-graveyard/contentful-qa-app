//
//  UIApplication+QA.h
//  Q&A
//
//  Created by Boris Bügling on 19/03/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CDAClient;

@interface UIApplication (QA)

@property (nonatomic) CDAClient* client;

@end
