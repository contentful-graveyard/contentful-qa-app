//
//  QAAppDelegate.h
//  Q&A
//
//  Created by Boris Bügling on 19/03/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CDAClient;

@interface QAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) CDAClient* client;
@property (strong, nonatomic) UIWindow *window;

@end
