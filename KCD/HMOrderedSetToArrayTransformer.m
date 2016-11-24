//
//  HMOrderedSetToArrayTransformer.m
//  KCD
//
//  Created by Hori,Masaki on 2016/11/23.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMOrderedSetToArrayTransformer.h"

@implementation HMOrderedSetToArrayTransformer
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSValueTransformer setValueTransformer:[self new] forName:@"HMOrderedSetToArrayTransformer"];
    });
}
+ (Class)transformedValueClass
{
    return [NSImage class];
}
+ (BOOL)allowsReverseTransformation
{
    return YES;
}
- (id)transformedValue:(id)value
{
    return [(NSOrderedSet *)value array];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSOrderedSet orderedSetWithArray:value];
}
@end
