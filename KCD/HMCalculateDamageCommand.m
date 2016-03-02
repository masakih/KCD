//
//  HMCalculateDamageCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/05/22.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMCalculateDamageCommand.h"

#import "HMTemporaryDataStore.h"
#import "HMServerDataStore.h"

#import "HMKCDamage.h"
#import "HMKCBattle.h"
#import "HMKCShipObject+Extensions.h"
#import "HMKCSlotItemObject.h"
#import "HMKCDeck+Extension.h"
#import "HMKCMasterSlotItemObject.h"

#define DAMAGE_CHECK 0

typedef NS_ENUM(NSUInteger, HMBattleType) {
	typeNormal = 0,
	typeCombinedAir,
	typeCombinedWater,
};

typedef NS_ENUM(NSUInteger, HMDamageControlMasterSlotItemID) {
	damageControl = 42,
	goddes = 43,
};

@interface HMCalculateDamageCommand ()
@property (nonatomic, strong) HMTemporaryDataStore *store;
@property HMBattleType battleType;
@property BOOL calcSecondFleet;
@end

@implementation HMCalculateDamageCommand

- (id)init
{
	self = [super init];
	if(self) {
		_store = [HMTemporaryDataStore oneTimeEditor];
	}
	return self;
}

- (nullable NSArray<HMKCBattle *> *)battles
{
	NSError *error = nil;
	NSArray<HMKCBattle *> *array = [self.store objectsWithEntityName:@"Battle"
													  predicate:nil
														  error:&error];
	if(error) {
		[self log:@"%s error: %@", __PRETTY_FUNCTION__, error];
		return nil;
	}
	
	return array;
}
- (nullable NSArray<HMKCDamage *> *)damagesWithSortDescriptors:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
{
	NSError *error = nil;
	NSArray<HMKCDamage *> *array = [self.store objectsWithEntityName:@"Damage"
													 sortDescriptors:sortDescriptors
														   predicate:nil
															   error:&error];
	if(error) {
		[self log:@"%s error: %@", __PRETTY_FUNCTION__, error];
		return nil;
	}
	return array;
}
- (nullable NSArray<HMKCShipObject *> *)shipsByDeckID:(NSNumber *)deckId store:(HMServerDataStore *)store
{
	NSError *error = nil;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", deckId];
	NSArray<HMKCDeck *> *decks = [store objectsWithEntityName:@"Deck"
													predicate:predicate
														error:&error];
	if(error) {
		[self log:@"%s error: %@", __PRETTY_FUNCTION__, error];
		return nil;
	}
	
	if(decks.count == 0) {
		[self log:@"Deck is invalid. %s", __PRETTY_FUNCTION__];
		return nil;
	}
	HMKCDeck *deck = decks[0];
	NSArray<NSNumber *> *shipIds = @[deck.ship_0, deck.ship_1, deck.ship_2, deck.ship_3, deck.ship_4, deck.ship_5];
	
	NSMutableArray<HMKCShipObject *> *ships = [NSMutableArray new];
	for(NSNumber *shipId in shipIds) {
		error = nil;
		NSArray<HMKCShipObject *> *ship = [store objectsWithEntityName:@"Ship"
																 error:&error
													   predicateFormat:@"id = %@", @([shipId integerValue])];
		if(error) {
			[self log:@"%s error: %@", __PRETTY_FUNCTION__, error];
		}
		if(ship.count != 0 && ![ship[0] isEqual:[NSNull null]]) {
			[ships addObject:ship[0]];
		}
	}
	
	return ships;
}
- (nullable HMKCShipObject *)shipByID:(NSNumber *)shipId store:(HMServerDataStore *)store
{
	if(shipId.integerValue < 1) return nil;
	
	NSError *error = nil;
	NSArray<HMKCShipObject *> *ships = [store objectsWithEntityName:@"Ship"
															  error:&error
													predicateFormat:@"id = %@", @([shipId integerValue])];
	if(error) {
		[self log:@"%s error: %@", __PRETTY_FUNCTION__, error];
		return nil;
	}
	if(ships.count == 0) {
		[self log:@"%s error: ship is not fount by id %@", __PRETTY_FUNCTION__, shipId];
		return nil;
	}
	
	return ships[0];
}

- (void)resetBattle
{
	NSManagedObjectContext *moc = self.store.managedObjectContext;
	NSArray<HMKCBattle *> *array = [self battles];
	for(HMKCBattle *object in array) {
		[moc deleteObject:object];
	}
		
	[self.store saveAction:nil];
}

- (void)resetDamage
{
	NSManagedObjectContext *moc = self.store.managedObjectContext;
	NSArray<HMKCDamage *> *array = [self damagesWithSortDescriptors:nil];
	for(HMKCDamage *object in array) {
		[moc deleteObject:object];
	}
	
	[self.store saveAction:nil];
}

- (void)startBattle
{
	NSManagedObjectContext *moc = self.store.managedObjectContext;
	
	// Battleエンティティ作成
	HMKCBattle *battle = [NSEntityDescription insertNewObjectForEntityForName:@"Battle"
													   inManagedObjectContext:moc];
	
	battle.deckId = @([[self.arguments valueForKey:@"api_deck_id"] integerValue]);
	battle.mapArea = @([[self.arguments valueForKey:@"api_maparea_id"] integerValue]);
	battle.mapInfo = @([[self.arguments valueForKey:@"api_mapinfo_no"] integerValue]);
	battle.no = @([[self.json valueForKeyPath:@"api_data.api_no"] integerValue]);
	
	[self.store saveAction:nil];
}

- (void)updateBattleCell
{
	NSArray<HMKCBattle *> *battles = [self battles];
	if(battles.count == 0) {
		NSLog(@"Battle is invalid.");
		return;
	}
	
	NSNumber *battleCell = battles[0].no;
	if(battleCell.integerValue == 0) {
		battleCell = nil;
	}
	if([self.api hasSuffix:@"next"]) {
		battleCell = nil;
	}
	battles[0].battleCell = battleCell;
	
	[self.store saveAction:nil];
}

- (void)nextCell
{
	NSArray<HMKCBattle *> *battles = [self battles];
	if(battles.count == 0) {
		NSLog(@"Battle is invalid.");
		return;
	}
	id cellNumber = [self.json valueForKeyPath:@"api_data.api_no"];
	id eventIDNumber = [self.json valueForKeyPath:@"api_data.api_event_id"];
	BOOL isBossCell = [eventIDNumber integerValue] == 5;
	
	battles[0].no = @([cellNumber integerValue]);
	battles[0].isBossCell = @(isBossCell);
	
	[self.store saveAction:nil];
}

- (void)buildDamageEntity
{
	NSArray<HMKCBattle *> *battles = [self battles];
	if(battles.count == 0) {
		NSLog(@"Battle is invalid.");
		return;
	}
	
	NSMutableArray *ships = [NSMutableArray array];
	NSArray<HMKCShipObject *> *firstFleetShips = [self shipsByDeckID:battles[0].deckId store:[HMServerDataStore defaultManager]];
	[ships addObjectsFromArray:firstFleetShips];
	while(ships.count != 6) {
		[ships addObject:[NSNull null]];
	}
	NSArray<HMKCShipObject *> *secondFleetShips = [self shipsByDeckID:@2 store:[HMServerDataStore defaultManager]];
	if(secondFleetShips) {
		[ships addObjectsFromArray:secondFleetShips];
		while(ships.count != 12) {
			[ships addObject:[NSNull null]];
		}
	}
	
	NSManagedObjectContext *moc = self.store.managedObjectContext;
	for(NSInteger idx = 0; idx < 12; idx++) {
		if(idx >= 6 && ships.count == 6) {
			return;
		}
		
		HMKCDamage *damage = [NSEntityDescription insertNewObjectForEntityForName:@"Damage"
														   inManagedObjectContext:moc];
		damage.battle = battles[0];
		damage.id = @(idx);
		HMKCShipObject *ship = ships[idx];
		if([ship isKindOfClass:[HMKCShipObject class]]) {
			damage.hp = ship.nowhp;
			damage.shipID = ship.id;
		}
	}
	
	[self.store saveAction:nil];
}
- (NSArray<HMKCDamage *> *)damages
{
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
	NSArray<HMKCDamage *> *array = [self damagesWithSortDescriptors:@[sortDescriptor]];
	
	NSInteger frendShipCount = 12;
	if(array.count != frendShipCount) {
		[self buildDamageEntity];
		array = [self damagesWithSortDescriptors:@[sortDescriptor]];
	}
	
	return [NSArray arrayWithArray:array];
}

- (void)calculateHougeki:(NSArray<HMKCDamage *> *)damages targetsKeyPath:(NSString *)targetKeyPath damageKeyPath:(NSString *)damageKeyPath
{
#if DAMAGE_CHECK
	NSLog(@"Start Hougeki %@", targetKeyPath);
#endif
	NSArray<NSArray<NSNumber *> *> *targetPositionArraysArray = [self.json valueForKeyPath:targetKeyPath];
	if(!targetPositionArraysArray || ![targetPositionArraysArray isKindOfClass:[NSArray class]]) return;
	
	NSArray<NSArray *> *hougeki1Damages = [self.json valueForKeyPath:damageKeyPath];
	NSInteger offset = self.calcSecondFleet ? 6 : 0;
	
	[targetPositionArraysArray enumerateObjectsUsingBlock:^(NSArray * _Nonnull targetPositions, NSUInteger i, BOOL * _Nonnull stop) {
		if(![targetPositions isKindOfClass:[NSArray class]]) {
			return;
		}
		
		[targetPositions enumerateObjectsUsingBlock:^(NSNumber * _Nonnull targetPositionNumber, NSUInteger j, BOOL * _Nonnull stop) {
			NSInteger targetPosition = [targetPositionNumber integerValue];
#if DAMAGE_CHECK
			NSLog(@"Hougeki target -> %ld", targetPosition + offset);
#endif
			// target is enemy
			if(targetPosition < 0 || targetPosition > 6) {
				return;
			}
			
			HMKCDamage *damageObject = damages[targetPosition - 1 + offset];
			NSInteger damage = [hougeki1Damages[i][j] integerValue];
			NSInteger hp = damageObject.hp.integerValue;
			NSInteger newHP = hp - damage;
			if(newHP <= 0) {
				HMKCShipObject *ship = [self shipByID:damageObject.shipID store:[HMServerDataStore defaultManager]];
				NSInteger efectiveHP = damageControlIfPossible(newHP, ship);
				if(efectiveHP != 0 && efectiveHP != newHP) {
					damageObject.useDamageControl = @YES;
				}
				newHP = efectiveHP;
			}
			damageObject.hp = @(newHP);
#if DAMAGE_CHECK
			NSLog(@"Hougeki %ld -> %ld", targetPosition + offset, damage);
#endif
		}];
	}];
	
	[self.store saveAction:nil];
}

- (void)calculateFDam:(NSArray<HMKCDamage *> *)damages fdamKeyPath:(NSString *)fdamKeyPath
{
#if DAMAGE_CHECK
	NSLog(@"Start FDam %@", fdamKeyPath);
#endif
	NSArray<NSNumber *> *koukuDamage = [self.json valueForKeyPath:fdamKeyPath];
	if(!koukuDamage || ![koukuDamage isKindOfClass:[NSArray class]]) return;
	
	NSInteger offset = self.calcSecondFleet ? 6 : 0;
	for(NSInteger i = 1; i <= 6; i++) {
		HMKCDamage *damageObject = damages[i - 1 + offset];
		NSInteger damage = [koukuDamage[i] integerValue];
		NSInteger hp = damageObject.hp.integerValue;
		NSInteger newHP = hp - damage;
		if(newHP <= 0) {
			HMKCShipObject *ship = [self shipByID:damageObject.shipID store:[HMServerDataStore defaultManager]];
			NSInteger efectiveHP = damageControlIfPossible(newHP, ship);
			if(efectiveHP != 0 && efectiveHP != newHP) {
				damageObject.useDamageControl = @YES;
			}
			newHP = efectiveHP;
		}
		damageObject.hp = @(newHP);
		
#if DAMAGE_CHECK
		NSLog(@"FDam %ld -> %ld", i + offset, damage);
#endif
	}
	
	[self.store saveAction:nil];
}

- (BOOL)isCombinedBattle
{
	return [self.api hasPrefix:@"/kcsapi/api_req_combined_battle"];
}

- (void)calculateBattle
{
	[self updateBattleCell];
	
	// 艦隊のチェック
	
	// Damage エンティティ作成6個
	NSArray<HMKCDamage *> *damages = [self damages];
	
	// koukuu
	[self calculateFDam:damages
			fdamKeyPath:@"api_data.api_kouku.api_stage3.api_fdam"];
	
	if(self.isCombinedBattle) {
		[self calculateFDam:damages
				fdamKeyPath:@"api_data.api_kouku2.api_stage3.api_fdam"];
		
		self.calcSecondFleet = YES;
		[self calculateFDam:damages
				fdamKeyPath:@"api_data.api_kouku.api_stage3_combined.api_fdam"];
		[self calculateFDam:damages
				fdamKeyPath:@"api_data.api_kouku2.api_stage3_combined.api_fdam"];
		self.calcSecondFleet = NO;
	} else {
		[self calculateFDam:damages
				fdamKeyPath:@"api_data.api_kouku2.api_stage3.api_fdam"];
	}
	
	// opening attack
	self.calcSecondFleet = self.isCombinedBattle;
	[self calculateFDam:damages
			fdamKeyPath:@"api_data.api_opening_atack.api_fdam"];
	self.calcSecondFleet = NO;
	
	// hougeki1
	self.calcSecondFleet = self.isCombinedBattle && self.battleType == typeCombinedAir;
	[self calculateHougeki:damages
			targetsKeyPath:@"api_data.api_hougeki1.api_df_list"
			 damageKeyPath:@"api_data.api_hougeki1.api_damage"];
	self.calcSecondFleet = NO;
	
	// hougeki2
	[self calculateHougeki:damages
			targetsKeyPath:@"api_data.api_hougeki2.api_df_list"
			 damageKeyPath:@"api_data.api_hougeki2.api_damage"];
	
	// hougeki3
	self.calcSecondFleet = self.isCombinedBattle && self.battleType == typeCombinedWater;
	[self calculateHougeki:damages
			targetsKeyPath:@"api_data.api_hougeki3.api_df_list"
			 damageKeyPath:@"api_data.api_hougeki3.api_damage"];
	self.calcSecondFleet = NO;

	// raigeki
	self.calcSecondFleet = self.isCombinedBattle;
	[self calculateFDam:damages
			fdamKeyPath:@"api_data.api_raigeki.api_fdam"];
	self.calcSecondFleet = NO;
	
	[self.store saveAction:nil];
}

- (void)calculateMidnightBattle
{
	[self updateBattleCell];
	
	// Damage 取得
	NSArray<HMKCDamage *> *damages = [self damages];
	
	// hougeki
	self.calcSecondFleet = self.isCombinedBattle;
	[self calculateHougeki:damages
			targetsKeyPath:@"api_data.api_hougeki.api_df_list"
			 damageKeyPath:@"api_data.api_hougeki.api_damage"];
	self.calcSecondFleet = NO;
	
	[self.store saveAction:nil];
}

NSInteger masterSlotItemIDbySlotItem(NSNumber *value)
{
	if(![value isKindOfClass:[NSNumber class]]) return 0;
	NSInteger slotItemID = [value integerValue];
	if(slotItemID == -1) return 0;
	if(slotItemID == 0) return 0;
	
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	
	NSError *error = nil;
	NSArray *array = [store objectsWithEntityName:@"SlotItem"
											error:&error
								  predicateFormat:@"id = %@", value];
	if([array count] == 0) {
		NSLog(@"SlotItem is invalid.");
		return 0;
	}
	
	HMKCSlotItemObject *slotItem = array[0];
	NSInteger masterSlotItemID = [slotItem.master_slotItem.id integerValue];
	
	return masterSlotItemID;
}

NSInteger damageControlIfPossible(NSInteger nowhp, HMKCShipObject *ship)
{
	if(nowhp < 0) nowhp = 0;
	
	NSInteger maxhp = ship.maxhp.integerValue;
	
	NSOrderedSet<HMKCSlotItemObject *> *items = ship.equippedItem;
	
	__block NSInteger newhp = nowhp;
	__block BOOL useDamageControl = NO;
	[items enumerateObjectsUsingBlock:^(HMKCSlotItemObject * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
		NSInteger masterSlotItemID = masterSlotItemIDbySlotItem(item.id);
		switch(masterSlotItemID) {
			case damageControl:
				newhp = maxhp * 0.2;
				useDamageControl = YES;
				*stop = YES;
				break;
			case goddes:
				newhp = maxhp;
				useDamageControl = YES;
				*stop = YES;
				break;
		}
	}];
	if(useDamageControl) {
		return newhp;
	}
	
	NSInteger masterSlotItemID = masterSlotItemIDbySlotItem(ship.slot_ex);
	switch(masterSlotItemID) {
		case damageControl:
			nowhp =  maxhp * 0.2;
			break;
		case goddes:
			nowhp =  maxhp;
			break;
	}
	
	return nowhp;
}

- (void)removeFirstDamageControlItemWithShip:(HMKCShipObject *)ship
{
	NSOrderedSet<HMKCSlotItemObject *> *items = ship.equippedItem;
	NSMutableOrderedSet<HMKCSlotItemObject *> *newItems = [items mutableCopy];
	[items enumerateObjectsUsingBlock:^(HMKCSlotItemObject * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
		NSInteger masterSlotItemID = masterSlotItemIDbySlotItem(item.id);
		switch(masterSlotItemID) {
			case goddes:
				ship.fuel = ship.maxFuel;
				ship.bull = ship.maxBull;
				// fallthrough
			case damageControl:
				[newItems removeObject:item];
				*stop = YES;
				break;
		}
	}];
	if(items.count != newItems.count) {
		ship.equippedItem = newItems;
		return;
	}
	
	NSInteger masterSlotItemID = masterSlotItemIDbySlotItem(ship.slot_ex);
	switch(masterSlotItemID) {
		case goddes:
			ship.fuel = ship.maxFuel;
			ship.bull = ship.maxBull;
			// fallthrough
		case damageControl:
			ship.slot_ex = @(-1);
			break;
	}
}
- (void)applyDamage
{
	// Damage 取得
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
	NSArray<HMKCDamage *> *damages = [self damagesWithSortDescriptors:@[sortDescriptor]];
	if(damages.count != 12) {
		[self log:@"Damage is invalid. count %lx", damages.count];
		return;
	}
	
	NSArray<HMKCBattle *> *array = [self battles];
	if(array.count == 0) {
		[self log:@"Battle is invalid. %s", __PRETTY_FUNCTION__];
		return;
	}
	
	HMServerDataStore *serverStore = [HMServerDataStore oneTimeEditor];
	for(HMKCDamage *damage in damages) {
		if(!damage.shipID || [damage.shipID isEqual:[NSNull null]]) { continue; }
		HMKCShipObject *ship = [self shipByID:damage.shipID store:serverStore];
		ship.nowhp = damage.hp;
		if(damage.useDamageControl.boolValue) {
			[self removeFirstDamageControlItemWithShip:ship];
		}
	}
	
	[self.store saveAction:nil];
}

- (void)execute
{
	if([self.api isEqualToString:@"/kcsapi/api_req_map/start"]) {
		[self resetBattle];
		[self startBattle];
		return;
	}
	if([self.api isEqualToString:@"/kcsapi/api_req_map/next"]) {
		[self nextCell];
		[self updateBattleCell];
		return;
	}
	
	if([self.api isEqualToString:@"/kcsapi/api_req_sortie/battle"]) {
		[self calculateBattle];
		return;
	}
	if([self.api isEqualToString:@"/kcsapi/api_req_sortie/airbattle"]) {
		[self calculateBattle];
		return;
	}
	if([self.api isEqualToString:@"/kcsapi/api_req_sortie/ld_airbattle"]) {
		[self calculateBattle];
		return;
	}
	
	if([self.api isEqualToString:@"/kcsapi/api_req_battle_midnight/battle"]
	   || [self.api isEqualToString:@"/kcsapi/api_req_battle_midnight/sp_midnight"]) {
		[self calculateMidnightBattle];
		return;
	}
	
	// combined battle
	if([self.api isEqualToString:@"/kcsapi/api_req_combined_battle/battle"]
	   || [self.api isEqualToString:@"/kcsapi/api_req_combined_battle/airbattle"]) {
		self.battleType = typeCombinedAir;
		[self calculateBattle];
		return;
	}
	if([self.api isEqualToString:@"/kcsapi/api_req_combined_battle/battle_water"]) {
	   self.battleType = typeCombinedWater;
		[self calculateBattle];
		return;
	}
	if([self.api isEqualToString:@"/kcsapi/api_req_combined_battle/ld_airbattle"]) {
		self.battleType = typeCombinedWater;
		[self calculateBattle];
		return;
	}
	
	if([self.api isEqualToString:@"/kcsapi/api_req_combined_battle/midnight_battle"]
	   || [self.api isEqualToString:@"/kcsapi/api_req_combined_battle/sp_midnight"]) {
		[self calculateMidnightBattle];
		return;
	}
	
	if([self.api isEqualToString:@"/kcsapi/api_req_sortie/battleresult"]
	   || [self.api isEqualToString:@"/kcsapi/api_req_combined_battle/battleresult"]) {
		[self applyDamage];
		[self resetDamage];
		return;
	}
	
	NSLog(@"undefined battle type");
}

@end
