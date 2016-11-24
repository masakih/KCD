//
//  HMKCAirBasePlaneInfo+CoreDataProperties.m
//  KCD
//
//  Created by Hori,Masaki on 2016/11/23.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMKCAirBasePlaneInfo+CoreDataProperties.h"

@implementation HMKCAirBasePlaneInfo (CoreDataProperties)

+ (NSFetchRequest<HMKCAirBasePlaneInfo *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"AirBasePlaneInfo"];
}

@dynamic squadron_id;
@dynamic state;
@dynamic slotid;
@dynamic cond;
@dynamic count;
@dynamic max_count;
@dynamic airBase;

@end
