//
//  HMActinKindTransformer.m
//  KCD
//
//  Created by Hori,Masaki on 2016/12/04.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMActinKindTransformer.h"

typedef NS_ENUM(NSUInteger, HMActionKind) {
    standBy,
    sortie,
    airDifence,
    shelter,
    rest,
};

@implementation HMActinKindTransformer
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSValueTransformer setValueTransformer:[self new] forName:@"HMActinKindTransformer"];
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
    HMActionKind actionKind = [value doubleValue];
    NSString *name = nil;
    
    switch(actionKind) {
        case standBy:
            name = NSLocalizedString(@"StandBy", @"Airbase action kind");
            break;
        case sortie:
            name = NSLocalizedString(@"Sortie", @"Airbase action kind");
            break;
        case airDifence:
            name = NSLocalizedString(@"Air Difence", @"Airbase action kind");
            break;
        case shelter:
            name = NSLocalizedString(@"Shelter", @"Airbase action kind");
            break;
        case rest:
            name = NSLocalizedString(@"Rest", @"Airbase action kind");
            break;
    }
    
    return name;
}
@end
