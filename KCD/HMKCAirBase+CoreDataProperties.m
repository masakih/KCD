//
//  HMKCAirBase+CoreDataProperties.m
//  KCD
//
//  Created by Hori,Masaki on 2016/11/23.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMKCAirBase+CoreDataProperties.h"

@implementation HMKCAirBase (CoreDataProperties)

+ (NSFetchRequest<HMKCAirBase *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"AirBase"];
}

@dynamic rid;
@dynamic name;
@dynamic area_id;
@dynamic distance;
@dynamic action_kind;
@dynamic planeInfo;

@end
