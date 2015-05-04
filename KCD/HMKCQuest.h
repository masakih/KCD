//
//  HMKCQuestList.h
//  KCD
//
//  Created by Hori,Masaki on 2015/04/22.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "HMKCManagedObject.h"


@interface HMKCQuest : HMKCManagedObject

@property (nonatomic, retain) NSNumber * bonus_flag;
@property (nonatomic, retain) NSNumber * category;
@property (nonatomic, retain) NSString * detail;
@property (nonatomic, retain) NSNumber * get_material_0;
@property (nonatomic, retain) NSNumber * get_material_1;
@property (nonatomic, retain) NSNumber * get_material_2;
@property (nonatomic, retain) NSNumber * get_material_3;
@property (nonatomic, retain) NSNumber * invalid_flag;
@property (nonatomic, retain) NSNumber * no;
@property (nonatomic, retain) NSNumber * progress_flag;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * type;

@end
