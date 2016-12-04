//
//  HMAreaNameTransformer.m
//  KCD
//
//  Created by Hori,Masaki on 2016/12/04.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMAreaNameTransformer.h"

#import "HMServerDataStore.h"
#import "HMKCMasterMapArea.h"


static NSMutableDictionary *cache = nil;

@implementation HMAreaNameTransformer
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSValueTransformer setValueTransformer:[self new] forName:@"HMAreaNameTransformer"];
        cache = [NSMutableDictionary dictionary];
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
    NSString *result = cache[value];
    if(result) return result;
    
    HMServerDataStore *store = [HMServerDataStore defaultManager];
    NSError *error = nil;
    
    NSArray<HMKCMasterMapArea *> *objects = [store objectsWithEntityName:@"MasterMapArea"
                                                                   error:&error
                                                         predicateFormat:@"id = %@", value];
    if(objects.count == 0) return nil;
    
    return objects[0].name;
}
@end
