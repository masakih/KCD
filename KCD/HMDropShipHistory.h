//
//  HMDropShipHistory.h
//  KCD
//
//  Created by Hori,Masaki on 2015/02/18.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HMDropShipHistory : NSManagedObject

@property (nonatomic, retain) NSString * shipName;
@property (nonatomic, retain) NSString * mapArea;
@property (nonatomic, retain) NSNumber * mapInfo;
@property (nonatomic, retain) NSNumber * mapCell;
@property (nonatomic, retain) NSString * mapAreaName;
@property (nonatomic, retain) NSString * mapInfoName;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * winRank;

@end
