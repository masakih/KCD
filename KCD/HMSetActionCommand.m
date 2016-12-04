//
//  HMSetActionCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2016/12/04.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMSetActionCommand.h"

#import "HMKCAirBase.h"
#import "HMKCAirBasePlaneInfo.h"
#import "HMKCMaterial.h"

#import "HMServerDataStore.h"


@implementation HMSetActionCommand
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [HMJSONCommand registerClass:self];
    });
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
    if([api isEqualToString:@"/kcsapi/api_req_air_corps/set_action"]) return YES;
    return NO;
}

- (void)execute
{
    HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
    
    NSString *areaId = self.arguments[@"api_area_id"];
    NSString *rIdsString = self.arguments[@"api_base_id"];
    NSString *actionKindsString = self.arguments[@"api_action_kind"];
    
    NSArray<NSString *> *rIds = [rIdsString componentsSeparatedByString:@","];
    NSArray<NSString *> *actionKinds = [actionKindsString componentsSeparatedByString:@","];
    
    [rIds enumerateObjectsUsingBlock:^(NSString * _Nonnull rId, NSUInteger idx, BOOL * _Nonnull stop) {
        NSError *error = nil;
        NSArray *airBases = [store objectsWithEntityName:@"AirBase"
                                         sortDescriptors:nil
                                                   error:&error
                                         predicateFormat:@"area_id == %@ AND rid == %@", @(areaId.integerValue), @(rId.integerValue)];
        if(airBases.count == 0) { return; }
        HMKCAirBase *airBase = airBases[0];
        airBase.action_kind = @(actionKinds[idx].integerValue);
    }];
}
@end
