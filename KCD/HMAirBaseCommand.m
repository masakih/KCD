//
//  HMAirBaseCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2016/11/21.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMAirBaseCommand.h"

#import "HMKCAirBase.h"
#import "HMKCAirBasePlaneInfo.h"


@implementation HMAirBaseCommand

- (NSString *)dataKey
{
    return @"api_data.api_air_base";
}

- (NSArray<NSString *> *)cmpositPrimaryKeys
{
    return @[@"area_id", @"rid"];
}

- (void)execute
{
    [self commitJSONToEntityNamed:@"AirBase"];
}

- (BOOL)handleExtraValue:(id)value forKey:(NSString *)key toObject:(NSManagedObject *)object
{
    if(![key isEqualToString:@"api_plane_info"]) return NO;
    
    HMKCAirBase *airbase = (HMKCAirBase *)object;
    if(airbase.planeInfo.count == 0) {
        NSManagedObjectContext *moc = object.managedObjectContext;
        NSMutableOrderedSet<HMKCAirBasePlaneInfo *> *newinfo = [NSMutableOrderedSet orderedSet];
        for(NSInteger i = 0; i < 4; i++) {
            HMKCAirBasePlaneInfo *info = [NSEntityDescription insertNewObjectForEntityForName:@"AirBasePlaneInfo"
                                                                       inManagedObjectContext:moc];
            [newinfo addObject:info];
        }
        airbase.planeInfo = newinfo;
    }
    
    NSArray<NSDictionary *> *planeInfos = value;
    NSOrderedSet<HMKCAirBasePlaneInfo *> *infos = airbase.planeInfo;
        
    for(NSInteger i = 0; i < 4; i++) {
        NSDictionary *planeInfo = planeInfos[i];
        HMKCAirBasePlaneInfo *info = infos[i];
        info.cond = planeInfo[@"api_cond"];
        info.count = planeInfo[@"api_count"];
        info.max_count = planeInfo[@"api_max_count"];
        info.slotid = planeInfo[@"api_slotid"];
        info.squadron_id = planeInfo[@"api_squadron_id"];
        info.state = planeInfo[@"api_state"];
        info.airBase = airbase;
    }
    
    return YES;
}

@end
