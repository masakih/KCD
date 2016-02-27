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

- (NSArray<HMKCDamage *> *)damages
{
	NSManagedObjectContext *moc = self.store.managedObjectContext;
	
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
	NSArray<HMKCDamage *> *array = [self damagesWithSortDescriptors:@[sortDescriptor]];
	
	NSInteger frendShipCount = 12;
	if(array.count != frendShipCount) {
		// Battleエンティティ取得
		NSArray<HMKCBattle *> *battles = [self battles];
		if(battles.count == 0) {
			NSLog(@"Battle is invalid.");
			return [NSMutableArray new];
		}
		
		// Damage エンティティ作成6個
		NSMutableArray<HMKCDamage *> *damages = [NSMutableArray new];
		for(NSInteger i = 0; i < frendShipCount; i++) {
			HMKCDamage *damage = [NSEntityDescription insertNewObjectForEntityForName:@"Damage"
															   inManagedObjectContext:moc];
			damage.battle = battles[0];
			damage.id = @(i);
			[damages addObject:damage];
		}
		array = damages;
	}
	
	return [NSArray arrayWithArray:array];
}

- (void)calculateHougeki:(NSArray<HMKCDamage *> *)damages targetsKeyPath:(NSString *)targetKeyPath damageKeyPath:(NSString *)damageKeyPath
{
#if DAMAGE_CHECK
	NSLog(@"Start Hougeki %@", targetKeyPath);
#endif
	id targetShips = [self.json valueForKeyPath:targetKeyPath];
	if(!targetShips || [targetShips isKindOfClass:[NSNull class]]) return;
	
	NSArray<NSArray *> *hougeki1Damages = [self.json valueForKeyPath:damageKeyPath];
	NSInteger i = 0;
	NSInteger offset = self.calcSecondFleet ? 6 : 0;
	for(NSArray *array in targetShips) {
		if(![array isKindOfClass:[NSArray class]]) {
			i++;
			continue;
		}
		
		NSInteger j = 0;
		for(id ship in array) {
			NSInteger target = [ship integerValue];
#if DAMAGE_CHECK
			NSLog(@"Hougeki target -> %ld", target + offset);
#endif
			if(target < 0 || target > 6) {
				j++;
				continue;
			}
			
			HMKCDamage *damageObject = damages[target - 1 + offset];
			NSInteger damage = [hougeki1Damages[i][j] integerValue];
			damage += damageObject.damage.integerValue;
			damageObject.damage = @(damage);
			
#if DAMAGE_CHECK
			NSLog(@"Hougeki %ld -> %ld", target + offset, damage);
#endif
			
			j++;
		}
		i++;
	}
}

- (void)calculateFDam:(NSArray<HMKCDamage *> *)damages fdamKeyPath:(NSString *)fdamKeyPath
{
#if DAMAGE_CHECK
	NSLog(@"Start FDam %@", fdamKeyPath);
#endif
	id koukuDamage = [self.json valueForKeyPath:fdamKeyPath];
	if(!koukuDamage || [koukuDamage isEqual:[NSNull null]]) return;
	
	NSInteger offset = self.calcSecondFleet ? 6 : 0;
	for(NSInteger i = 1; i <= 6; i++) {
		HMKCDamage *damageObject = damages[i - 1 + offset];
		NSInteger damage = [koukuDamage[i] integerValue];
		damage += damageObject.damage.integerValue;
		damageObject.damage = @(damage);
		
#if DAMAGE_CHECK
		NSLog(@"FDam %ld -> %ld", i + offset, damage);
#endif
	}
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
	__block NSMutableOrderedSet<HMKCSlotItemObject *> *newItems = [items mutableCopy];
	[items enumerateObjectsUsingBlock:^(HMKCSlotItemObject * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
		NSInteger masterSlotItemID = masterSlotItemIDbySlotItem(item.id);
		switch(masterSlotItemID) {
			case damageControl:
				newhp = maxhp * 0.2;
				[newItems removeObject:item];
				*stop = YES;
				break;
			case goddes:
				newhp = maxhp;
				[newItems removeObject:item];
				ship.fuel = ship.maxFuel;
				ship.bull = ship.maxBull;
				*stop = YES;
				break;
		}
	}];
	if(items.count != newItems.count) {
		ship.equippedItem = newItems;
		return newhp;
	}
	
	NSInteger masterSlotItemID = masterSlotItemIDbySlotItem(ship.slot_ex);
	switch(masterSlotItemID) {
		case damageControl:
			nowhp =  maxhp * 0.2;
			ship.slot_ex = @(-1);
			break;
		case goddes:
			nowhp =  maxhp;
			ship.fuel = ship.maxFuel;
			ship.bull = ship.maxBull;
			ship.slot_ex = @(-1);
			break;
	}
	
	return nowhp;
}

- (nullable NSMutableArray<HMKCShipObject *> *)shipsByDeckID:(NSNumber *)deckId store:(HMServerDataStore *)store
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
	NSArray *shipIds = @[deck.ship_0, deck.ship_1, deck.ship_2, deck.ship_3, deck.ship_4, deck.ship_5];
	
	NSMutableArray<HMKCShipObject *> *ships = [NSMutableArray new];
	for(id shipId in shipIds) {
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
	NSNumber *deckId = array[0].deckId;
	BOOL firstRun = YES;
	for(NSInteger i = 0; i < 2; i++) {
		NSMutableArray<HMKCShipObject *> *ships = [self shipsByDeckID:deckId store:serverStore];
		NSUInteger shipCount = ships.count;
		NSUInteger offset = (self.isCombinedBattle && !firstRun) ? 6 : 0;
		for(NSInteger i = 0; i < shipCount; i++) {
			NSInteger damage = damages[i + offset].damage.integerValue;
			NSInteger nowhp = ships[i].nowhp.integerValue;
			nowhp -= damage;
			if(nowhp <= 0) {
				nowhp = damageControlIfPossible(nowhp, ships[i]);
			}
			ships[i].nowhp = @(nowhp);
		}
		
		deckId = @2;
		firstRun = NO;
		
		if(!self.isCombinedBattle) break;
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
