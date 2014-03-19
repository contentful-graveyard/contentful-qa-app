//
//  NSTextAttachment+Field.m
//  Q&A
//
//  Created by Boris Bügling on 19/03/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <objc/runtime.h>

#import "NSTextAttachment+Field.h"

static const char* CDAFieldKey = "CDAFieldKey";

@implementation NSTextAttachment (Field)

-(CDAField *)field {
    return objc_getAssociatedObject(self, CDAFieldKey);
}

-(void)setField:(CDAField *)field {
    objc_setAssociatedObject(self, CDAFieldKey, field, OBJC_ASSOCIATION_ASSIGN);
}

@end
