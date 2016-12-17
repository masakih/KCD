//
//  HMServerDataStore.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/29.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMServerDataStore.h"

#import "HMKCShipObject+Extensions.h"
#import "HMKCDeck+Extension.h"
#import "HMKCSlotItemObject.h"
#import "HMKCMasterSlotItemObject.h"


@implementation HMServerDataStore
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[self defaultManager];
	});
}

- (NSString *)modelName
{
	return @"KCD";
}
- (NSString *)storeFileName
{
#if COREDATA_STORE_TYPE == 0
	return @"KCD.storedata";
#else
	return @"KCD.storedata.xml";
#endif
}
- (NSString *)storeType
{
#if COREDATA_STORE_TYPE == 0
	return NSSQLiteStoreType;
#else
	return NSXMLStoreType;
#endif
}
- (NSDictionary *)storeOptions
{
	NSDictionary *options = @{
							  NSMigratePersistentStoresAutomaticallyOption : @YES,
							  NSInferMappingModelAutomaticallyOption : @YES
							  };
	return options;
}
- (BOOL)deleteAndRetry
{
	return YES;
}
@end

@implementation HMServerDataStore (HMAccessor)

- (nullable NSArray<HMKCShipObject *> *)shipsByDeckID:(nonnull NSNumber *)deckId
{
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", deckId];
    NSArray<HMKCDeck *> *decks = [self objectsWithEntityName:@"Deck"
                                                   predicate:predicate
                                                       error:&error];
    if(error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
        return nil;
    }
    
    if(decks.count == 0) {
        NSLog(@"Deck is invalid. %s", __PRETTY_FUNCTION__);
        return nil;
    }
    HMKCDeck *deck = decks[0];
    NSArray<NSNumber *> *shipIds = @[deck.ship_0, deck.ship_1, deck.ship_2, deck.ship_3, deck.ship_4, deck.ship_5];
    
    NSMutableArray<HMKCShipObject *> *ships = [NSMutableArray new];
    for(NSNumber *shipId in shipIds) {
        error = nil;
        NSArray<HMKCShipObject *> *ship = [self objectsWithEntityName:@"Ship"
                                                                error:&error
                                                      predicateFormat:@"id = %@", @([shipId integerValue])];
        if(error) {
            NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
        }
        if(ship.count != 0 && ![ship[0] isEqual:[NSNull null]]) {
            [ships addObject:ship[0]];
        }
    }
    
    return ships;
}
- (nullable HMKCShipObject *)shipByID:(nonnull NSNumber *)shipId
{
    if(shipId.integerValue < 1) return nil;
    
    NSError *error = nil;
    NSArray<HMKCShipObject *> *ships = [self objectsWithEntityName:@"Ship"
                                                             error:&error
                                                   predicateFormat:@"id = %@", @([shipId integerValue])];
    if(error) {
        NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
        return nil;
    }
    if(ships.count == 0) {
        NSLog(@"%s error: ship is not fount by id %@", __PRETTY_FUNCTION__, shipId);
        return nil;
    }
    
    return ships[0];
}
- (nullable NSNumber *) masterSlotItemIDbySlotItem:(nonnull NSNumber *)value
{
    if(![value isKindOfClass:[NSNumber class]]) return 0;
    NSInteger slotItemID = [value integerValue];
    if(slotItemID == -1) return 0;
    if(slotItemID == 0) return 0;
    
    NSError *error = nil;
    NSArray *array = [self objectsWithEntityName:@"SlotItem"
                                           error:&error
                                 predicateFormat:@"id = %@", value];
    if([array count] == 0) {
        NSLog(@"SlotItem is invalid.");
        return 0;
    }
    
    HMKCSlotItemObject *slotItem = array[0];
    return slotItem.master_slotItem.id;
}
@end
