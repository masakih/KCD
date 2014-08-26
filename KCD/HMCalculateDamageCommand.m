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

@interface HMCalculateDamageCommand ()
@property (nonatomic, strong) HMTemporaryDataStore *store;
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
	NSManagedObjectContext *moc = self.store.managedObjectContext;
	
	NSArray *array = [self.store objectsWithEntityName:@"Battle"
										predicate:nil
											error:NULL];
	for(id object in array) {
		[moc deleteObject:object];
	}
		
	[self.store saveAction:nil];
}

- (void)resetDamage
{
	NSManagedObjectContext *moc = self.store.managedObjectContext;
	
	NSArray *array = [self.store objectsWithEntityName:@"Damage"
							   predicate:nil
								   error:NULL];
	for(id object in array) {
		[moc deleteObject:object];
	}
		
	[self.store saveAction:nil];
}

- (void)startBattle
{
	NSManagedObjectContext *moc = self.store.managedObjectContext;
	
	// Battleエンティティ作成
	id battle = [NSEntityDescription insertNewObjectForEntityForName:@"Battle"
											  inManagedObjectContext:moc];
	
	[battle setValue:@([[self.arguments valueForKey:@"api_deck_id"] integerValue]) forKeyPath:@"deckId"];
	[battle setValue:@([[self.arguments valueForKey:@"api_maparea_id"] integerValue]) forKeyPath:@"mapArea"];
	[battle setValue:@([[self.arguments valueForKey:@"api_mapinfo_no"] integerValue]) forKeyPath:@"mapInfo"];
	
	[self.store saveAction:nil];
}

- (NSMutableArray *)damages
{
	NSManagedObjectContext *moc = self.store.managedObjectContext;
	
	NSError *error = nil;
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
	NSArray *array = [self.store objectsWithEntityName:@"Damage"
									   sortDescriptors:@[sortDescriptor]
											 predicate:nil
												 error:&error];
	// TODO: error handling
	
	NSInteger frendShipCount = 12;
	if(array.count != frendShipCount) {
		// Battleエンティティ取得
		NSArray *battles = [self.store objectsWithEntityName:@"Battle"
												   predicate:nil
													   error:NULL];
		if(battles.count == 0) {
			NSLog(@"Battle is invalid.");
			return [NSMutableArray new];
		}
		id battle = battles[0];
		
		// Damage エンティティ作成6個
		NSMutableArray *damages = [NSMutableArray new];
		for(NSInteger i = 0; i < frendShipCount; i++) {
			id damage = [NSEntityDescription insertNewObjectForEntityForName:@"Damage"
													  inManagedObjectContext:moc];
			[damage setValue:battle forKeyPath:@"battle"];
			[damage setValue:@(i) forKeyPath:@"id"];
			[damages addObject:damage];
		}
		array = damages;
	}
	
	return [NSMutableArray arrayWithArray:array];
}

- (void)calculateHougeki:(NSMutableArray *)damages targetsKeyPath:(NSString *)targetKeyPath damageKeyPath:(NSString *)damageKeyPath
{
	id targetShips = [self.json valueForKeyPath:targetKeyPath];
	if(!targetShips || [targetShips isKindOfClass:[NSNull class]]) return;
	
	id hougeki1Damages = [self.json valueForKeyPath:damageKeyPath];
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
			if(target < 0 || target > 6) {
				j++;
				continue;
			}
			
			id damageObject = [damages objectAtIndex:target - 1 + offset];
			NSInteger damage = [[[hougeki1Damages objectAtIndex:i] objectAtIndex:j] integerValue];
			damage += [[damageObject valueForKey:@"damage"] integerValue];
			[damageObject setValue:@(damage) forKeyPath:@"damage"];
			
			j++;
		}
		i++;
	}
}

- (void)calculateFDam:(NSMutableArray *)damages fdamKeyPath:(NSString *)fdamKeyPath
{
	id koukuDamage = [self.json valueForKeyPath:fdamKeyPath];
	if(!koukuDamage || [koukuDamage isEqual:[NSNull null]]) return;
	
	NSInteger offset = self.calcSecondFleet ? 6 : 0;
	for(NSInteger i = 1; i <= 6; i++) {
		id damageObject = [damages objectAtIndex:i - 1 + offset];
		NSInteger damage = [[koukuDamage objectAtIndex:i] integerValue];
		damage += [[damageObject valueForKey:@"damage"] integerValue];
		[damageObject setValue:@(damage) forKeyPath:@"damage"];
	}
}

- (BOOL)isCombinedBattle
{
	return [self.api hasPrefix:@"/kcsapi/api_req_combined_battle"];
}

- (void)calculateBattle
{
	// 艦隊のチェック
	
	// Damage エンティティ作成6個
	NSMutableArray *damages = [self damages];
	
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
	}
	
	// opening attack
	self.calcSecondFleet = self.isCombinedBattle;
	[self calculateFDam:damages
			fdamKeyPath:@"api_data.api_opening_atack.api_fdam"];
	self.calcSecondFleet = NO;
	
	// hougeki1
	self.calcSecondFleet = self.isCombinedBattle;
	[self calculateHougeki:damages
			targetsKeyPath:@"api_data.api_hougeki1.api_df_list"
			 damageKeyPath:@"api_data.api_hougeki1.api_damage"];
	self.calcSecondFleet = NO;
	
	// hougeki2
	[self calculateHougeki:damages
			targetsKeyPath:@"api_data.api_hougeki2.api_df_list"
			 damageKeyPath:@"api_data.api_hougeki2.api_damage"];
	
	// hougeki3
	[self calculateHougeki:damages
			targetsKeyPath:@"api_data.api_hougeki3.api_df_list"
			 damageKeyPath:@"api_data.api_hougeki3.api_damage"];
	
	// raigeki
	self.calcSecondFleet = self.isCombinedBattle;
	[self calculateFDam:damages
			fdamKeyPath:@"api_data.api_raigeki.api_fdam"];
	self.calcSecondFleet = NO;
	
	[self.store saveAction:nil];
}

- (void)calculateMidnightBattle
{
	// Damage 取得
	NSMutableArray *damages = [self damages];
	
	// hougeki
	self.calcSecondFleet = self.isCombinedBattle;
	[self calculateHougeki:damages
			targetsKeyPath:@"api_data.api_hougeki.api_df_list"
			 damageKeyPath:@"api_data.api_hougeki.api_damage"];
	self.calcSecondFleet = NO;
	
	[self.store saveAction:nil];
}

- (NSArray *)deckWithNumber:(NSNumber *)number
{
	return [NSArray array];
}
- (void)applyDamage
{
	// Damage 取得
	NSArray *damages = nil;
	
	NSError *error = nil;
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
	damages = [self.store objectsWithEntityName:@"Damage"
								sortDescriptors:@[sortDescriptor]
									  predicate:nil
										  error:&error];
	// TODO: error handling
	
	if(damages.count != 12) {
		NSLog(@"Damage is invalid. count %lxd", damages.count);
		return;
	}
	
	NSArray *array = [self.store objectsWithEntityName:@"Battle"
										predicate:nil
											error:NULL];
	if(array.count == 0) {
		NSLog(@"Battle is invalid. %s", __PRETTY_FUNCTION__);
		return;
	}
	
	HMServerDataStore *serverStore = [HMServerDataStore oneTimeEditor];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", [array[0] valueForKey:@"deckId"]];
	BOOL firstRun = YES;
	for(NSInteger i = 0; i < 2; i++) {
		// 艦隊メンバーを取得
		NSArray *decks = [serverStore objectsWithEntityName:@"Deck"
												  predicate:predicate
													  error:NULL];
		
		if(decks.count == 0) {
			NSLog(@"Deck is invalid. %s", __PRETTY_FUNCTION__);
			return;
		}
		id deck = decks[0];
		NSMutableArray *shipIds = [NSMutableArray new];
		[shipIds addObject:[deck valueForKey:@"ship_0"]];
		[shipIds addObject:[deck valueForKey:@"ship_1"]];
		[shipIds addObject:[deck valueForKey:@"ship_2"]];
		[shipIds addObject:[deck valueForKey:@"ship_3"]];
		[shipIds addObject:[deck valueForKey:@"ship_4"]];
		[shipIds addObject:[deck valueForKey:@"ship_5"]];
		
		NSMutableArray *ships = [NSMutableArray new];
		for(id shipId in shipIds) {
			NSArray *ship = [serverStore objectsWithEntityName:@"Ship"
														 error:NULL
											   predicateFormat:@"id = %@", @([shipId integerValue])];
			if(ship.count != 0 && ![ship[0] isEqual:[NSNull null]]) {
				[ships addObject:ship[0]];
			}
		}
		
		NSUInteger shipCount = ships.count;
		NSUInteger offset = (self.isCombinedBattle && !firstRun) ? 6 : 0;
		for(NSInteger i = 0; i < shipCount; i++) {
			id ship = ships[i];
			NSInteger damage = [[damages[i + offset] valueForKey:@"damage"] integerValue];
			NSInteger nowhp = [[ship valueForKey:@"nowhp"] integerValue];
			nowhp -= damage;
			[ship setValue:@(nowhp) forKeyPath:@"nowhp"];
		}
		
		predicate = [NSPredicate predicateWithFormat:@"id = %@", @2];
		firstRun = NO;
		
		if(!self.isCombinedBattle) break;
	}
	
	[serverStore saveAction:nil];
}

- (void)execute
{
	if([self.api isEqualToString:@"/kcsapi/api_req_map/start"]) {
		[self resetBattle];
		[self startBattle];
		return;
	}
	if([self.api isEqualToString:@"/kcsapi/api_req_sortie/battle"]) {
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
