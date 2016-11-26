//
//  HMAirCorpsSupplyCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2016/11/26.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMAirCorpsSupplyCommand.h"

#import "HMKCAirBase.h"
#import "HMKCAirBasePlaneInfo.h"
#import "HMKCMaterial.h"

#import "HMServerDataStore.h"


@implementation HMAirCorpsSupplyCommand
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [HMJSONCommand registerClass:self];
    });
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
    if([api isEqualToString:@"/kcsapi/api_req_air_corps/supply"]) return YES;
    return NO;
}

- (void)execute
{
    HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
    NSError *error = nil;
    
    NSString *areaId = self.arguments[@"api_area_id"];
    NSString *rId = self.arguments[@"api_base_id"];
    NSString *squadronIdsString = self.arguments[@"api_squadron_id"];
    NSArray *airBases = [store objectsWithEntityName:@"AirBase"
                                     sortDescriptors:nil
                                               error:&error
                                     predicateFormat:@"area_id == %@ AND rid == %@", @(areaId.integerValue), @(rId.integerValue)];
    if(airBases.count == 0) { return; }
    
    HMKCAirBase *airBase = airBases[0];
    NSOrderedSet *planes = airBase.planeInfo;
    
    NSDictionary *json = self.json;
    NSDictionary *data = json[@"api_data"];
    NSArray *planeInfos = data[@"api_plane_info"];
    if(planeInfos.count == 0) { return; }
    
    NSArray *squadronIds = [squadronIdsString componentsSeparatedByString:@","];
    NSLog(@"sq count -> %ld", squadronIds.count);
    
    [squadronIds enumerateObjectsUsingBlock:^(NSString * _Nonnull squadronId, NSUInteger idx, BOOL * _Nonnull stop) {
        if(planes.count < squadronId.integerValue) { return; }
        HMKCAirBasePlaneInfo *plane = planes[squadronId.integerValue - 1];
        
        if(planeInfos.count <= idx) { return; }
        NSDictionary *planeInfo = planeInfos[idx];
        
        plane.count = planeInfo[@"api_cond"];
        plane.slotid = planeInfo[@"api_slotid"];
        plane.state = planeInfo[@"api_state"];
        plane.count = planeInfo[@"api_count"];
        plane.max_count = planeInfo[@"api_max_count"];
    }];
    
    airBase.distance = data[@"api_distance"];
    
    NSArray *materials = [store objectsWithEntityName:@"Material"
                                            predicate:nil
                                                error:&error];
    if(materials.count == 0) { return; }
    
    HMKCMaterial *material = materials[0];
    material.bauxite = data[@"api_after_bauxite"];
    material.fuel = data[@"api_after_fuel"];
}

@end
