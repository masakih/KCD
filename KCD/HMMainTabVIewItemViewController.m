//
//  HMMainTabVIewItemViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2016/12/07.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMMainTabVIewItemViewController.h"

@interface HMMainTabVIewItemViewController ()

@end

@implementation HMMainTabVIewItemViewController

- (NSArray *)shipTypeCategories
{
    static NSArray *categories = nil;
    
    if(categories) return categories;
    
    categories = @[
                   @[@(0)],	// dummy
                   @[@2],	// destoryer
                   @[@3, @4],	// leght cruiser
                   @[@5,@6],	// heavy crusier
                   @[@7, @11, @16, @18],	// aircraft carrier
                   @[@8, @9, @10, @12],	// battle ship
                   @[@13, @14],	// submarine
                   @[@1, @15, @17, @19]
                   ];
    return categories;
}
- (NSPredicate *)predicateForShipType:(HMShipType)shipType
{
    NSPredicate *predicate = nil;
    NSArray *categories = [self shipTypeCategories];
    switch (shipType) {
        case kHMAllType:
            predicate = nil;
            break;
        case kHMDestroyer:
        case kHMLightCruiser:
        case kHMHeavyCruiser:
        case kHMAircraftCarrier:
        case kHMBattleShip:
        case kHMSubmarine:
            predicate = [NSPredicate predicateWithFormat:@"master_ship.stype.id IN %@", categories[shipType]];
            break;
            
        case kHMOtherType:
        {
            NSMutableArray *ommitTypes = [NSMutableArray new];
            for(int i = kHMDestroyer; i < kHMOtherType; i++) {
                [ommitTypes addObjectsFromArray:categories[i]];
            }
            predicate = [NSPredicate predicateWithFormat:@"NOT master_ship.stype.id IN %@", ommitTypes];
        }
            break;
    }
    
    return predicate;
}

@end
