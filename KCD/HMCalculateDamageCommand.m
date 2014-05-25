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

@implementation HMCalculateDamageCommand

- (void)resetDamage
{
	HMTemporaryDataStore *store = [HMTemporaryDataStore oneTimeEditor];
	NSManagedObjectContext *moc = store.managedObjectContext;
	
	NSArray *array = [store objectsWithEntityName:@"Battle"
										predicate:nil
											error:NULL];
	for(id object in array) {
		[moc deleteObject:object];
	}
	
	array = [store objectsWithEntityName:@"Damage"
							   predicate:nil
								   error:NULL];
	for(id object in array) {
		[moc deleteObject:object];
	}
	
	[store saveAction:nil];
}

- (void)startBattle
{
	HMTemporaryDataStore *store = [HMTemporaryDataStore oneTimeEditor];
	NSManagedObjectContext *moc = store.managedObjectContext;
	
	// Battleエンティティ作成
	id battle = [NSEntityDescription insertNewObjectForEntityForName:@"Battle"
											  inManagedObjectContext:moc];
	
	[battle setValue:@([[self.arguments valueForKey:@"api_deck_id"] integerValue]) forKeyPath:@"deckId"];
	[battle setValue:@([[self.arguments valueForKey:@"api_maparea_id"] integerValue]) forKeyPath:@"mapArea"];
	[battle setValue:@([[self.arguments valueForKey:@"api_mapinfo_no"] integerValue]) forKeyPath:@"mapInfo"];
	
	[store saveAction:nil];
}

- (void)calculateBattle
{
	HMTemporaryDataStore *store = [HMTemporaryDataStore oneTimeEditor];
	NSManagedObjectContext *moc = store.managedObjectContext;
	
	// 艦隊のチェック
	
	// Battleエンティティ取得
	NSArray *battles = [store objectsWithEntityName:@"Battle"
										  predicate:nil
											  error:NULL];
	if(battles.count == 0) {
		NSLog(@"Battle is invalid.");
		return;
	}
	id battle = battles[0];
	
	// Damage エンティティ作成6個
	NSMutableArray *damages = [NSMutableArray new];
	for(NSInteger i = 0; i < 6; i++) {
		id damage = [NSEntityDescription insertNewObjectForEntityForName:@"Damage"
												  inManagedObjectContext:moc];
		[damage setValue:battle forKeyPath:@"battle"];
		[damage setValue:@(i) forKeyPath:@"id"];
		[damages addObject:damage];
	}
	
	// koukuu
	do {
		id koukuDamage = [self.json valueForKeyPath:@"api_data.api_kouku.api_stage3.api_fdam"];
		if(!koukuDamage || [koukuDamage isEqual:[NSNull null]]) break;
		for(NSInteger i = 1; i <= 6; i++) {
			NSInteger damage = [[koukuDamage objectAtIndex:i] integerValue];
			id damageObject = [damages objectAtIndex:i];
			[damageObject setValue:@(damage) forKeyPath:@"damage"];
		}
	} while(NO);
	
	// opening attack
	do {
		id openigDamage = [self.json valueForKeyPath:@"api_data.api_opening_atack.api_fdam"];
		if(!openigDamage || [openigDamage isEqual:[NSNull null]]) break;
		for(NSInteger i = 0; i < 6; i++) {
			NSInteger damage = [[openigDamage objectAtIndex:i] integerValue];
			id damageObject = [damages objectAtIndex:i];
			damage += [[damageObject valueForKey:@"damage"] integerValue];
			[damageObject setValue:@(damage) forKeyPath:@"damage"];
		}
	} while(NO);
	
	
	// hougeki1
	{
		id targetShips = [self.json valueForKeyPath:@"api_data.api_hougeki1.api_df_list"];
		id hougeki1Damages = [self.json valueForKeyPath:@"api_data.api_hougeki1.api_damage"];
		NSInteger i = 0;
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
				
				id damageObject = [damages objectAtIndex:target];
				NSInteger damage = [[[hougeki1Damages objectAtIndex:i] objectAtIndex:j] integerValue];
				damage += [[damageObject valueForKey:@"damage"] integerValue];
				[damageObject setValue:@(damage) forKeyPath:@"damage"];
				
				j++;
			}
			i++;
		}
	}

	// hougeki2
	do {
		id hasHougeki2 = [self.json valueForKeyPath:@"api_data.api_hougeki2"];
		if(!hasHougeki2 || [hasHougeki2 isEqual:[NSNull null]]) break;
		
		id targetShips = [self.json valueForKeyPath:@"api_data.api_hougeki2.api_df_list"];
		id hougeki1Damages = [self.json valueForKeyPath:@"api_data.api_hougeki2.api_damage"];
		NSInteger i = 0;
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
				
				id damageObject = [damages objectAtIndex:target];
				NSInteger damage = [[[hougeki1Damages objectAtIndex:i] objectAtIndex:j] integerValue];
				damage += [[damageObject valueForKey:@"damage"] integerValue];
				[damageObject setValue:@(damage) forKeyPath:@"damage"];
				
				j++;
			}
			i++;
		}
	} while(NO);
	
	
	// raigeki
	do {
		id raigekiDamage = [self.json valueForKeyPath:@"api_data.api_raigeki.api_fdam"];
		if(!raigekiDamage || [raigekiDamage isEqual:[NSNull null]]) break;
		for(NSInteger i = 1; i <= 6; i++) {
			NSInteger damage = [[raigekiDamage objectAtIndex:i] integerValue];
			id damageObject = [damages objectAtIndex:i - 1];
			damage += [[damageObject valueForKey:@"damage"] integerValue];
			[damageObject setValue:@(damage) forKeyPath:@"damage"];
		}
	} while(NO);
	
	[store saveAction:nil];
}

- (void)calculateMidnightBattle
{
	HMTemporaryDataStore *store = [HMTemporaryDataStore oneTimeEditor];
	NSManagedObjectContext *moc = store.managedObjectContext;
	
	// Damage 取得
	NSArray *damages = nil;
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Damage"];
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO];
	[request setSortDescriptors:@[sortDescriptor]];
	damages = [moc executeFetchRequest:request error:NULL];
	if(damages.count != 6) {
		NSLog(@"Damage is invalid.");
		return;
	}
	
	// hougeki1
	{
		id targetShips = [self.json valueForKeyPath:@"api_data.api_hougeki1.api_df_list"];
		id hougeki1Damages = [self.json valueForKeyPath:@"api_data.api_hougeki1.api_damage"];
		NSInteger i = 0;
		NSInteger j = 0;
		for(NSArray *array in targetShips) {
			for(id ship in array) {
				NSInteger target = [ship integerValue];
				if(target > 6) {
					j++;
					continue;
				}
				
				id damageObject = [damages objectAtIndex:target];
				NSInteger damage = [[[hougeki1Damages objectAtIndex:i] objectAtIndex:j] integerValue];
				damage += [[damageObject valueForKey:@"damage"] integerValue];
				[damageObject setValue:@(damage) forKeyPath:@"damage"];
				
				j++;
			}
			i++;
		}
	}
	
	[store saveAction:nil];
}

- (void)applyDamage
{
	HMTemporaryDataStore *store = [HMTemporaryDataStore oneTimeEditor];
	NSManagedObjectContext *moc = store.managedObjectContext;
	
	// Damage 取得
	NSArray *damages = nil;
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Damage"];
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO];
	[request setSortDescriptors:@[sortDescriptor]];
	damages = [moc executeFetchRequest:request error:NULL];
	if(damages.count != 6) {
		NSLog(@"Damage is invalid.");
		return;
	}
	
	HMServerDataStore *serverStore = [HMServerDataStore oneTimeEditor];
	
	// TODO:
	NSLog(@"MUST IMPLEMENT!!");
	
	[serverStore saveAction:nil];
}

- (void)execute
{
	if([self.api isEqualToString:@"/kcsapi/api_req_map/start"]) {
		[self resetDamage];
		[self startBattle];
		return;
	}
	if([self.api isEqualToString:@"/kcsapi/api_req_sortie/battle"]) {
		[self calculateBattle];
		return;
	}
	if([self.api isEqualToString:@"/kcsapi/api_req_battle_midnight/battle"]) {
		[self calculateMidnightBattle];
		return;
	}
	if([self.api isEqualToString:@"/kcsapi/api_req_sortie/battleresult"]) {
		[self applyDamage];
		[self resetDamage];
		return;
	}
	
	NSLog(@"undefined battle type");
}

@end
