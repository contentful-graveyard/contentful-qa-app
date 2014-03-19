//
//  NSTextAttachment+Field.h
//  Q&A
//
//  Created by Boris Bügling on 19/03/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CDAField;

@interface NSTextAttachment (Field)

@property (nonatomic) CDAField* field;

@end
