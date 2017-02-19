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
    typeEachCombinedAir,
    typeEachCombinedWater,
    
    typeEnemyCombined,
};

typedef NS_ENUM(NSUInteger, HMDamageControlMasterSlotItemID) {
	damageControl = 42,
	goddes = 43,
};

@interface HMCalculateDamageCommand ()
@property (nonatomic, strong) HMTemporaryDataStore *store;
@property HMBattleType battleType;
@property BOOL calcSecondFleet;
@property BOOL calcEachFleet;
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

- (void)resetBattle
{
	NSArray<HMKCBattle *> *array = self.store.battles;
	for(HMKCBattle *object in array) {
		[self.store deleteObject:object];
	}
		
	[self.store saveAction:nil];
}

- (void)resetDamage
{
	NSArray<HMKCDamage *> *array = [self.store damagesWithSortDescriptors:nil];
	for(HMKCDamage *object in array) {
		[self.store deleteObject:object];
	}
	
	[self.store saveAction:nil];
}

- (void)startBattle
{
	// Battleエンティティ作成
	HMKCBattle *battle = [self.store insertNewObjectForEntityForName:@"Battle"];
	
	battle.deckId = @([[self.arguments valueForKey:@"api_deck_id"] integerValue]);
	battle.mapArea = @([[self.arguments valueForKey:@"api_maparea_id"] integerValue]);
	battle.mapInfo = @([[self.arguments valueForKey:@"api_mapinfo_no"] integerValue]);
	battle.no = @([[self.json valueForKeyPath:@"api_data.api_no"] integerValue]);
	
	[self.store saveAction:nil];
}

- (void)updateBattleCell
{
	NSArray<HMKCBattle *> *battles = self.store.battles;
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
	NSArray<HMKCBattle *> *battles = self.store.battles;
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
	NSArray<HMKCBattle *> *battles = self.store.battles;
	if(battles.count == 0) {
		NSLog(@"Battle is invalid.");
		return;
	}
	
	NSMutableArray *ships = [NSMutableArray array];
	NSArray<HMKCShipObject *> *firstFleetShips = [[HMServerDataStore defaultManager] shipsByDeckID:battles[0].deckId];
	[ships addObjectsFromArray:firstFleetShips];
	while(ships.count != 6) {
		[ships addObject:[NSNull null]];
	}
	NSArray<HMKCShipObject *> *secondFleetShips = [[HMServerDataStore defaultManager] shipsByDeckID:@2];
	if(secondFleetShips) {
		[ships addObjectsFromArray:secondFleetShips];
		while(ships.count != 12) {
			[ships addObject:[NSNull null]];
		}
	}
	
	for(NSInteger idx = 0; idx < 12; idx++) {
		if(idx >= 6 && ships.count == 6) {
			return;
		}
		
		HMKCDamage *damage = [self.store insertNewObjectForEntityForName:@"Damage"];
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
	NSArray<HMKCDamage *> *array = [self.store damagesWithSortDescriptors:@[sortDescriptor]];
	
	NSInteger frendShipCount = 12;
	if(array.count != frendShipCount) {
		[self buildDamageEntity];
		array = [self.store damagesWithSortDescriptors:@[sortDescriptor]];
	}
	
	return [NSArray arrayWithArray:array];
}

- (void)calculateHougeki:(NSArray<HMKCDamage *> *)damages baseKeyPath:(NSString *)baseKeyPath
{
    NSString *targetKeyPath = [baseKeyPath stringByAppendingString:@".api_df_list"];
    NSString *damageKeyPath = [baseKeyPath stringByAppendingString:@".api_damage"];
    NSString *eFlagKeyPath = [baseKeyPath stringByAppendingString:@".api_at_eflag"];
    
	NSArray<NSArray<NSNumber *> *> *targetPositionArraysArray = [self.json valueForKeyPath:targetKeyPath];
	if(!targetPositionArraysArray || ![targetPositionArraysArray isKindOfClass:[NSArray class]]) return;
    
#if DAMAGE_CHECK
    NSLog(@"Start Hougeki %@", baseKeyPath);
#endif
	
	NSArray<NSArray *> *hougeki1Damages = [self.json valueForKeyPath:damageKeyPath];
	NSInteger offset = self.calcSecondFleet ? 6 : 0;
    
    NSArray<NSNumber *> *eFlags = [self.json valueForKeyPath:eFlagKeyPath];
	
	[targetPositionArraysArray enumerateObjectsUsingBlock:^(NSArray * _Nonnull targetPositions, NSUInteger i, BOOL * _Nonnull stop) {
		if(![targetPositions isKindOfClass:[NSArray class]]) {
			return;
		}
		
		[targetPositions enumerateObjectsUsingBlock:^(NSNumber * _Nonnull targetPositionNumber, NSUInteger j, BOOL * _Nonnull stop) {
			NSInteger targetPosition = targetPositionNumber.integerValue;
#if DAMAGE_CHECK
			NSLog(@"Hougeki target -> %ld", targetPosition + offset);
#endif
			// target is enemy
            if(eFlags) {
                NSInteger eFlag = eFlags[i].integerValue;
                if(eFlag != 1) return;
            } else {
                if(self.calcEachFleet) {
                    if(targetPosition < 0 || targetPosition > 12) {
                        return;
                    }
                } else {
                    if(targetPosition < 0 || targetPosition > 6) {
                        return;
                    }
                }
            }
            
			HMKCDamage *damageObject = damages[targetPosition - 1 + offset];
			NSInteger damage = [hougeki1Damages[i][j] integerValue];
			NSInteger hp = damageObject.hp.integerValue;
			NSInteger newHP = hp - damage;
			if(newHP <= 0) {
				HMKCShipObject *ship = [[HMServerDataStore defaultManager] shipByID:damageObject.shipID];
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

- (void)calculateFDam:(NSArray<HMKCDamage *> *)damages baseKeyPath:(NSString *)baseKeyPath
{
    NSString *fdamKeyPath = [baseKeyPath stringByAppendingString:@".api_fdam"];
    
	NSArray<NSNumber *> *koukuDamage = [self.json valueForKeyPath:fdamKeyPath];
	if(!koukuDamage || ![koukuDamage isKindOfClass:[NSArray class]]) return;
    
#if DAMAGE_CHECK
    NSLog(@"Start FDam %@", fdamKeyPath);
#endif
	
	NSInteger offset = self.calcSecondFleet ? 6 : 0;
    [koukuDamage enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(idx == 0) return;
        
        HMKCDamage *damageObject = damages[idx - 1 + offset];
        NSInteger damage = obj.integerValue;
        NSInteger hp = damageObject.hp.integerValue;
        NSInteger newHP = hp - damage;
        if(newHP <= 0) {
            HMKCShipObject *ship = [[HMServerDataStore defaultManager] shipByID:damageObject.shipID];
            NSInteger efectiveHP = damageControlIfPossible(newHP, ship);
            if(efectiveHP != 0 && efectiveHP != newHP) {
                damageObject.useDamageControl = @YES;
            }
            newHP = efectiveHP;
        }
        damageObject.hp = @(newHP);
        
#if DAMAGE_CHECK
        NSLog(@"FDam %ld -> %ld", idx + offset, damage);
#endif
    }];
	
	[self.store saveAction:nil];
}

- (BOOL)isCombinedBattle
{
    switch(self.battleType) {
        case typeCombinedWater:
        case typeCombinedAir:
        case typeEachCombinedWater:
        case typeEachCombinedAir:
            return YES;
        default:
            //
            break;
    }
    return NO;
}

- (void)calcKouku:(NSArray<HMKCDamage *> *)damages
{
    [self calculateFDam:damages
            baseKeyPath:@"api_data.api_kouku.api_stage3"];
    
    [self calculateFDam:damages
            baseKeyPath:@"api_data.api_kouku2.api_stage3"];
    
    // 艦隊　戦闘艦隊
    // 連合vs通常（水上）　第２
    // 連合vs通常（機動）　第２
    // 連合vs連合（水上）　第２ use kouku nor kouku2
    // 連合vs連合（機動）　第１ use kouku nor kouku2
    if(self.isCombinedBattle) {
        self.calcSecondFleet = YES;
        [self calculateFDam:damages
                baseKeyPath:@"api_data.api_kouku.api_stage3_combined"];
        [self calculateFDam:damages
                baseKeyPath:@"api_data.api_kouku2.api_stage3_combined"];
        self.calcSecondFleet = NO;
    }
}
- (void)calcOpeningAtack:(NSArray<HMKCDamage *> *)damages
{
    // 艦隊　戦闘艦隊
    // 連合vs通常（水上）　第２
    // 連合vs通常（機動）　第２
    // 連合vs連合（水上）　第２
    // 連合vs連合（機動）　第２　全体
    self.calcSecondFleet = self.battleType == typeCombinedAir || self.battleType == typeCombinedWater;
    [self calculateFDam:damages
            baseKeyPath:@"api_data.api_opening_atack"];
    self.calcSecondFleet = NO;
}
- (void)calcOpeningTaisen:(NSArray<HMKCDamage *> *)damages
{
    self.calcSecondFleet = self.isCombinedBattle;
    [self calculateHougeki:damages
               baseKeyPath:@"api_data.api_opening_taisen"];
    self.calcSecondFleet = NO;
}
- (void)calcHougeki1:(NSArray<HMKCDamage *> *)damages
{
    // 艦隊　戦闘艦隊
    // 連合vs通常（水上）　第１
    // 連合vs通常（機動）　第２
    // 連合vs連合（水上）　第１
    // 連合vs連合（機動）　第1
    self.calcSecondFleet = self.battleType == typeCombinedAir;
    [self calculateHougeki:damages
               baseKeyPath:@"api_data.api_hougeki1"];
    self.calcSecondFleet = NO;
}
- (void)calcHougeki2:(NSArray<HMKCDamage *> *)damages
{
    // 艦隊　戦闘艦隊
    // 連合vs通常（水上）　第１
    // 連合vs通常（機動）　第１
    // 連合vs連合（水上）　第１　全体
    // 連合vs連合（機動）　第１
    self.calcEachFleet = self.battleType == typeEachCombinedWater;
    [self calculateHougeki:damages
               baseKeyPath:@"api_data.api_hougeki2"];
    self.calcEachFleet = NO;
}
- (void)calcHougeki3:(NSArray<HMKCDamage *> *)damages
{
    // 艦隊　戦闘艦隊
    // 連合vs通常（水上）　第２
    // 連合vs通常（機動）　第１
    // 連合vs連合（水上）　第２
    // 連合vs連合（機動）　第１　全体
    self.calcSecondFleet = self.battleType == typeCombinedWater;
    self.calcEachFleet = self.battleType == typeEachCombinedAir;
    [self calculateHougeki:damages
               baseKeyPath:@"api_data.api_hougeki3"];
    self.calcSecondFleet = NO;
    self.calcEachFleet = NO;
}
- (void)calcRaigeki:(NSArray<HMKCDamage *> *)damages
{
    // 艦隊　戦闘艦隊
    // 連合vs通常（水上）　第２
    // 連合vs通常（機動）　第２
    // 連合vs連合（水上）　第２　全体
    // 連合vs連合（機動）　第２　全体
    self.calcSecondFleet = self.isCombinedBattle;
    if(self.battleType == typeEachCombinedWater || self.battleType == typeEachCombinedAir) {
        self.calcSecondFleet = NO;
    }
    [self calculateFDam:damages
            baseKeyPath:@"api_data.api_raigeki"];
    self.calcSecondFleet = NO;
}
- (void)calculateMidnightBattle
{
    [self updateBattleCell];
    
    // Damage 取得
    NSArray<HMKCDamage *> *damages = [self damages];
    
    // 艦隊　戦闘艦隊
    // 連合vs通常（水上）　第２
    // 連合vs通常（機動）　第２
    // 連合vs連合（水上）　第２
    // 連合vs連合（機動）　第２
    self.calcSecondFleet = self.isCombinedBattle;
    [self calculateHougeki:damages
               baseKeyPath:@"api_data.api_hougeki"];
    self.calcSecondFleet = NO;
    
    [self.store saveAction:nil];
}

- (void)calculateBattle
{
	[self updateBattleCell];
    
	// Damage エンティティ作成6個
	NSArray<HMKCDamage *> *damages = [self damages];
    
    [self calcKouku:damages];
    [self calcOpeningTaisen:damages];
    [self calcOpeningAtack:damages];
    [self calcHougeki1:damages];
    [self calcHougeki2:damages];
    [self calcHougeki3:damages];
    [self calcRaigeki:damages];
	
	[self.store saveAction:nil];
}
- (void)calcCombinedBattleAir
{
    [self updateBattleCell];
    
    // Damage エンティティ作成6個
    NSArray<HMKCDamage *> *damages = [self damages];
    
    [self calcKouku:damages];
    [self calcOpeningTaisen:damages];
    [self calcOpeningAtack:damages];
    [self calcHougeki1:damages];
    [self calcRaigeki:damages];
    [self calcHougeki2:damages];
    [self calcHougeki3:damages];
    
    [self.store saveAction:nil];
}
- (void)calcEachBattleAir
{
    [self updateBattleCell];
    
    // Damage エンティティ作成6個
    NSArray<HMKCDamage *> *damages = [self damages];
    
    [self calcKouku:damages];
    [self calcOpeningTaisen:damages];
    [self calcOpeningAtack:damages];
    [self calcHougeki1:damages];
    [self calcHougeki2:damages];
    [self calcRaigeki:damages];
    [self calcHougeki3:damages];
    
    [self.store saveAction:nil];
}
- (void)calcEnemyCombinedBattle
{
    // same phase as combined air
    [self calcCombinedBattleAir];
}

NSInteger damageControlIfPossible(NSInteger nowhp, HMKCShipObject *ship)
{
	if(nowhp < 0) nowhp = 0;
	
	NSInteger maxhp = ship.maxhp.integerValue;
	
	NSOrderedSet<HMKCSlotItemObject *> *items = ship.equippedItem;
	
    HMServerDataStore *store = [HMServerDataStore defaultManager];
	__block NSInteger newhp = nowhp;
	__block BOOL useDamageControl = NO;
	[items enumerateObjectsUsingBlock:^(HMKCSlotItemObject * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger masterSlotItemID = [store masterSlotItemIDbySlotItem:item.id].integerValue;
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
	
    NSInteger masterSlotItemID = [store masterSlotItemIDbySlotItem:ship.slot_ex].integerValue;
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
    HMServerDataStore *store = [HMServerDataStore defaultManager];
    
	NSOrderedSet<HMKCSlotItemObject *> *items = ship.equippedItem;
	NSMutableOrderedSet<HMKCSlotItemObject *> *newItems = [items mutableCopy];
	[items enumerateObjectsUsingBlock:^(HMKCSlotItemObject * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger masterSlotItemID = [store masterSlotItemIDbySlotItem:item.id].integerValue;
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
	
    NSInteger masterSlotItemID = [store masterSlotItemIDbySlotItem:ship.slot_ex].integerValue;
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
	NSArray<HMKCDamage *> *damages = [self.store damagesWithSortDescriptors:@[sortDescriptor]];
	if(damages.count != 12) {
		[self log:@"Damage is invalid. count %lx", damages.count];
		return;
	}
	
	NSArray<HMKCBattle *> *array = self.store.battles;
	if(array.count == 0) {
		[self log:@"Battle is invalid. %s", __PRETTY_FUNCTION__];
		return;
	}
	
	HMServerDataStore *serverStore = [HMServerDataStore oneTimeEditor];
	for(HMKCDamage *damage in damages) {
		if(!damage.shipID || [damage.shipID isEqual:[NSNull null]]) { continue; }
		HMKCShipObject *ship = [serverStore shipByID:damage.shipID];
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
    
    if([self.api isEqualToString:@"/kcsapi/api_req_combined_battle/ec_battle"]) {
        self.battleType = typeEnemyCombined;
        [self calcEnemyCombinedBattle];
        return;
    }
	
	// combined battle
	if([self.api isEqualToString:@"/kcsapi/api_req_combined_battle/battle"]
	   || [self.api isEqualToString:@"/kcsapi/api_req_combined_battle/airbattle"]) {
		self.battleType = typeCombinedAir;
		[self calcCombinedBattleAir];
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
    if([self.api isEqualToString:@"/kcsapi/api_req_combined_battle/each_battle"]) {
        self.battleType = typeEachCombinedAir;
        [self calcEachBattleAir];
        return;
    }
    if([self.api isEqualToString:@"/kcsapi/api_req_combined_battle/each_battle_water"]) {
        self.battleType = typeEachCombinedWater;
        [self calculateBattle];
        return;
    }
	
	if([self.api isEqualToString:@"/kcsapi/api_req_combined_battle/midnight_battle"]
       || [self.api isEqualToString:@"/kcsapi/api_req_combined_battle/sp_midnight"]) {
        [self calculateMidnightBattle];
        return;
    }
    if([self.api isEqualToString:@"/kcsapi/api_req_combined_battle/ec_midnight_battle"]) {
        self.battleType = typeCombinedWater;
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
