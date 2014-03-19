//
//  QAAppDelegate.m
//  Q&A
//
//  Created by Boris Bügling on 19/03/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "CDASpaceSelectionViewController.h"
#import "QAAppDelegate.h"

@implementation QAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[CDASpaceSelectionViewController new]];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
