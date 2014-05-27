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

- (void)resetBattle
{
	HMTemporaryDataStore *store = [HMTemporaryDataStore oneTimeEditor];
	NSManagedObjectContext *moc = store.managedObjectContext;
	
	NSArray *array = [store objectsWithEntityName:@"Battle"
										predicate:nil
											error:NULL];
	for(id object in array) {
		[moc deleteObject:object];
	}
	
	[store saveAction:nil];
}

- (void)resetDamage
{
	printf("\n");
	
	HMTemporaryDataStore *store = [HMTemporaryDataStore oneTimeEditor];
	NSManagedObjectContext *moc = store.managedObjectContext;
	
	NSArray *array = [store objectsWithEntityName:@"Damage"
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
	printf("Kouku damages-> ");
	do {
		id koukuDamage = [self.json valueForKeyPath:@"api_data.api_kouku.api_stage3.api_fdam"];
		if(!koukuDamage || [koukuDamage isEqual:[NSNull null]]) break;
		for(NSInteger i = 1; i <= 6; i++) {
			NSInteger damage = [[koukuDamage objectAtIndex:i] integerValue];
			
			printf("%zd,%zd    ", i - 1, damage);
			
			id damageObject = [damages objectAtIndex:i - 1];
			[damageObject setValue:@(damage) forKeyPath:@"damage"];
		}
	} while(NO);
	printf("\n");
	
	// opening attack
	printf("Opening attack damages-> ");
	do {
		id openigDamage = [self.json valueForKeyPath:@"api_data.api_opening_atack.api_fdam"];
		if(!openigDamage || [openigDamage isEqual:[NSNull null]]) break;
		for(NSInteger i = 1; i <= 6; i++) {
			NSInteger damage = [[openigDamage objectAtIndex:1] integerValue];
			
			printf("%zd,%zd    ", i, damage);
			
			id damageObject = [damages objectAtIndex:i - 1];
			damage += [[damageObject valueForKey:@"damage"] integerValue];
			[damageObject setValue:@(damage) forKeyPath:@"damage"];
		}
	} while(NO);
	printf("\n");
	
	// hougeki1
	printf("Hougeki1 damages-> ");
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
				
				id damageObject = [damages objectAtIndex:target - 1];
				NSInteger damage = [[[hougeki1Damages objectAtIndex:i] objectAtIndex:j] integerValue];
				
				printf("%zd,%zd    ", target - 1, damage);
				
				damage += [[damageObject valueForKey:@"damage"] integerValue];
				[damageObject setValue:@(damage) forKeyPath:@"damage"];
				
				j++;
			}
			i++;
		}
	}
	printf("\n");
	
	// hougeki2
	printf("Hougeki2 damages-> ");
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
				
				id damageObject = [damages objectAtIndex:target - 1];
				NSInteger damage = [[[hougeki1Damages objectAtIndex:i] objectAtIndex:j] integerValue];
				
				printf("%zd,%zd    ", target - 1, damage);
				
				damage += [[damageObject valueForKey:@"damage"] integerValue];
				[damageObject setValue:@(damage) forKeyPath:@"damage"];
				
				j++;
			}
			i++;
		}
	} while(NO);
	printf("\n");
	
	// raigeki
	printf("Raigeki damages-> ");
	do {
		id raigekiDamage = [self.json valueForKeyPath:@"api_data.api_raigeki.api_fdam"];
		if(!raigekiDamage || [raigekiDamage isEqual:[NSNull null]]) break;
		for(NSInteger i = 1; i <= 6; i++) {
			NSInteger damage = [[raigekiDamage objectAtIndex:i] integerValue];
			
			printf("%zd,%zd    ", i - 1, damage);
			
			id damageObject = [damages objectAtIndex:i - 1];
			damage += [[damageObject valueForKey:@"damage"] integerValue];
			[damageObject setValue:@(damage) forKeyPath:@"damage"];
		}
	} while(NO);
	printf("\n");
	
	[store saveAction:nil];
}

- (void)calculateMidnightBattle
{
	HMTemporaryDataStore *store = [HMTemporaryDataStore oneTimeEditor];
	NSManagedObjectContext *moc = store.managedObjectContext;
	
	// Damage 取得
	NSArray *damages = nil;
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Damage"];
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
	[request setSortDescriptors:@[sortDescriptor]];
	damages = [moc executeFetchRequest:request error:NULL];
	if(damages.count != 6) {
		NSLog(@"Damage is invalid.");
		return;
	}
	
	// hougeki
	printf("Yasen damages-> ");
	{
		id targetShips = [self.json valueForKeyPath:@"api_data.api_hougeki.api_df_list"];
		id hougeki1Damages = [self.json valueForKeyPath:@"api_data.api_hougeki.api_damage"];
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
				
				id damageObject = [damages objectAtIndex:target - 1];
				NSInteger damage = [[[hougeki1Damages objectAtIndex:i] objectAtIndex:j] integerValue];
				
				printf("%zd,%zd    ", target - 1, damage);
				
				damage += [[damageObject valueForKey:@"damage"] integerValue];
				[damageObject setValue:@(damage) forKeyPath:@"damage"];
				
				j++;
			}
			i++;
		}
	}
	printf("\n");
	
	[store saveAction:nil];
}

- (NSArray *)deckWithNumber:(NSNumber *)number
{
	return [NSArray array];
}
- (void)applyDamage
{
	HMTemporaryDataStore *store = [HMTemporaryDataStore oneTimeEditor];
	NSManagedObjectContext *moc = store.managedObjectContext;
	
	// Damage 取得
	NSArray *damages = nil;
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Damage"];
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
	[request setSortDescriptors:@[sortDescriptor]];
	damages = [moc executeFetchRequest:request error:NULL];
	if(damages.count != 6) {
		NSLog(@"Damage is invalid.");
		return;
	}
	
	NSArray *array = [store objectsWithEntityName:@"Battle"
										predicate:nil
											error:NULL];
	if(array.count == 0) {
		NSLog(@"Battle is invalid. %s", __PRETTY_FUNCTION__);
		return;
	}
	
	HMServerDataStore *serverStore = [HMServerDataStore oneTimeEditor];
	
	NSArray *decks = [serverStore objectsWithEntityName:@"Deck"
												  error:NULL
										predicateFormat:@"id = %@", [array[0] valueForKey:@"deckId"]];
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
	for(NSInteger i = 0; i < shipCount; i++) {
		id ship = ships[i];
		NSInteger damage = [[damages[i] valueForKey:@"damage"] integerValue];
		NSInteger nowhp = [[ship valueForKey:@"nowhp"] integerValue];
		nowhp -= damage;
		[ship setValue:@(nowhp) forKeyPath:@"nowhp"];
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
