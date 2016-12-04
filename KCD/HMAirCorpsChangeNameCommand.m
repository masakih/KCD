//
//  HMAirCorpsChangeNameCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2016/12/04.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMAirCorpsChangeNameCommand.h"

#import "HMKCAirBase.h"
#import "HMKCAirBasePlaneInfo.h"
#import "HMKCMaterial.h"

#import "HMServerDataStore.h"

@implementation HMAirCorpsChangeNameCommand
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [HMJSONCommand registerClass:self];
    });
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
    if([api isEqualToString:@"/kcsapi/api_req_air_corps/change_name"]) return YES;
    return NO;
}

- (void)execute
{
    HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
    NSError *error = nil;
    
    NSString *areaId = self.arguments[@"api_area_id"];
    NSString *rId = self.arguments[@"api_base_id"];
    NSArray *airBases = [store objectsWithEntityName:@"AirBase"
                                     sortDescriptors:nil
                                               error:&error
                                     predicateFormat:@"area_id == %@ AND rid == %@", @(areaId.integerValue), @(rId.integerValue)];
    if(airBases.count == 0) { return; }
    
    HMKCAirBase *airBase = airBases[0];
    airBase.name = self.arguments[@"api_name"];
}
@end
