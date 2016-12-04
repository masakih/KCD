//
//  HMAirbasePlaneStateTransformer.m
//  KCD
//
//  Created by Hori,Masaki on 2016/12/04.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMAirbasePlaneStateTransformer.h"

@implementation HMAirbasePlaneStateTransformer
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSValueTransformer setValueTransformer:[self new] forName:@"HMAirbasePlaneStateTransformer"];
    });
}
+ (Class)transformedValueClass
{
    return [NSString class];
}
+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if([value integerValue] == 2) {
        return NSLocalizedString(@"rotating", @"HMAirbasePlaneStateTransformer");
    }
    return nil;
}
@end
