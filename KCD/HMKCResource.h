//
//  HMKCResource.h
//  KCD
//
//  Created by Hori,Masaki on 2015/08/03.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HMKCResource : NSManagedObject

@property (nonatomic, retain) NSNumber * kaihatusizai;
@property (nonatomic, retain) NSNumber * steel;
@property (nonatomic, retain) NSNumber * fuel;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * bull;
@property (nonatomic, retain) NSNumber * bauxite;
@property (nonatomic, retain) NSNumber * screw;
@property (nonatomic, retain) NSNumber * kousokukenzo;
@property (nonatomic, retain) NSNumber * kousokushuhuku;
@property (nonatomic, retain) NSNumber * minute;
@property (nonatomic, retain) NSNumber * experience;


@end
