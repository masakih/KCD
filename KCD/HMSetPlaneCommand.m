//
//  HMSetPlaneCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2016/11/24.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMSetPlaneCommand.h"

#import "HMKCAirBase.h"
#import "HMKCAirBasePlaneInfo.h"
#import "HMKCMaterial.h"

#import "HMServerDataStore.h"


@implementation HMSetPlaneCommand
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [HMJSONCommand registerClass:self];
    });
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
    if([api isEqualToString:@"/kcsapi/api_req_air_corps/set_plane"]) return YES;
    return NO;
}

- (void)execute
{
    HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
    NSError *error = nil;
    
    NSString *areaId = self.arguments[@"api_area_id"];
    NSString *rId = self.arguments[@"api_base_id"];
    NSString *squadronId = self.arguments[@"api_squadron_id"];
    NSArray *airBases = [store objectsWithEntityName:@"AirBase"
                                      sortDescriptors:nil
                                                error:&error
                                      predicateFormat:@"area_id == %@ AND rid == %@", @(areaId.integerValue), @(rId.integerValue)];
    if(airBases.count == 0) { return; }
    
    HMKCAirBase *airBase = airBases[0];
    NSOrderedSet *planes = airBase.planeInfo;
    if(planes.count < squadronId.integerValue) { return; }
    HMKCAirBasePlaneInfo *plane = planes[squadronId.integerValue - 1];
    
    NSDictionary *json = self.json;
    NSDictionary *data = json[@"api_data"];
    NSArray *planeInfo = data[@"api_plane_info"];
    if(planeInfo.count == 0) { return; }
    NSDictionary *planeInfo0 = planeInfo[0];
    
    plane.count = planeInfo0[@"api_cond"];
    plane.slotid = planeInfo0[@"api_slotid"];
    plane.state = planeInfo0[@"api_state"];
    plane.count = planeInfo0[@"api_count"];
    plane.max_count = planeInfo0[@"api_max_count"];
    
    airBase.distance = data[@"api_distance"];
    
    NSArray *materials = [store objectsWithEntityName:@"Material"
                                            predicate:nil
                                                error:&error];
    if(materials.count == 0) { return; }
    
    HMKCMaterial *material = materials[0];
    material.bauxite = data[@"api_after_bauxite"];
    
}
@end
