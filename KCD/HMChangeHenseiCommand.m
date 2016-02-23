//
//  HMChangeHenseiCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/06/15.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMChangeHenseiCommand.h"

#import "HMServerDataStore.h"
#import "HMKCDeck+Extension.h"

#import "HMChangeHenseiNotification.h"


@interface HMChangeHenseiCommand ()
@property (nonatomic, strong) HMServerDataStore *store;
@end

@implementation HMChangeHenseiCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_req_hensei/change"];
}

- (HMServerDataStore *)store
{
	if(_store) return _store;
	
	_store = [HMServerDataStore oneTimeEditor];
	return _store;
}

- (void)printFleet
{
	NSError *error = nil;
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
	NSArray<HMKCDeck *> *decks = [self.store objectsWithEntityName:@"Deck"
												   sortDescriptors:@[sortDescriptor]
														 predicate:nil
															 error:&error];
	// TODO: error handling
	
	NSMutableArray *ships = [NSMutableArray new];
	for(HMKCDeck *deck in decks) {
		for(NSUInteger i = 0; i < 6; i++) {
			[ships addObject:[deck valueForKey:[NSString stringWithFormat:@"ship_%ld", i]]];
		}
	}
	
	for(int i = 0; i < 4; i++) {
		fprintf(stderr, "Fleet %d\n", i+1);
		for(int j = 0; j < 6; j++) {
			fprintf(stderr, "%d -> %ld\n", j+1, [ships[i*6+j] integerValue]);
		}
	}
	fprintf(stderr, "\n");
}

- (void)packFleet
{
	NSError *error = nil;
	NSArray<HMKCDeck *> *decks = [self.store objectsWithEntityName:@"Deck"
														 predicate:nil
															 error:&error];
	// TODO: error handling
	
	for(HMKCDeck *deck in decks) {
		BOOL needsPack = NO;
		for(NSInteger i = 0; i < 6; i++) {
			NSInteger shipId = [[deck valueForKey:[NSString stringWithFormat:@"ship_%ld", i]] integerValue];
			if(!needsPack && shipId == -1) {
				needsPack = YES;
				continue;
			}
			if(needsPack) {
				[deck setValue:@(shipId) forKey:[NSString stringWithFormat:@"ship_%ld", i - 1]];
				
				if(i == 5) {
					[deck setValue:@(-1) forKey:@"ship_5"];
				}
			}
		}
	}
}

- (void)excludeShipsWithoutFlag
{
	NSInteger deckNumber = [[self.arguments valueForKey:@"api_id"] integerValue];
	
	NSError *error = nil;
	NSArray<HMKCDeck *> *decks = [self.store objectsWithEntityName:@"Deck"
															 error:&error
												   predicateFormat:@"id = %ld", deckNumber];
	// TODO: error handling
	HMKCDeck *deck = decks[0];
	
	for(NSInteger i = 1; i < 6; i++) {
		[deck setValue:@(-1) forKey:[NSString stringWithFormat:@"ship_%ld", i]];
	}
}

// api_ship_id の値
// ship_id > 0 : 艦娘のID　append or replace
// ship_id == -1 : remove.
// ship_id == -2 : remove all without flag ship.
- (void)execute
{
	NSInteger deckNumber = [[self.arguments valueForKey:@"api_id"] integerValue];
	NSInteger shipId = [[self.arguments valueForKey:@"api_ship_id"] integerValue];
	NSInteger shipIndex = [[self.arguments valueForKey:@"api_ship_idx"] integerValue];
	
	if(shipId < -1) {
		[self excludeShipsWithoutFlag];
		self.store = nil;
		
		[self notifyWithType:kHMChangeHenseiRemoveAllWithoutFlagship
				 fleetNumber:@(deckNumber)
					position:nil
					  shipID:nil
		  replaceFleetNumber:nil
			 replacePosition:nil
			   replaceShipID:nil];
		return;
	}
	
	NSError *error = nil;
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
	NSArray<HMKCDeck *> *decks = [self.store objectsWithEntityName:@"Deck"
												   sortDescriptors:@[sortDescriptor]
														 predicate:nil
															 error:&error];
	// TODO: error handling
	
	NSMutableArray *ships = [NSMutableArray new];
	for(HMKCDeck *deck in decks) {
		for(NSUInteger i = 0; i < 6; i++) {
			[ships addObject:[deck valueForKey:[NSString stringWithFormat:@"ship_%ld", i]]];
		}
	}
		
	// すでに編成されているか？ どこに？
	BOOL alreadyInFleet = [ships containsObject:@(shipId)];
	NSInteger shipDeckNumber = -1;
	NSInteger shipDeckIndex = -1;
	if(alreadyInFleet) {
		NSInteger index = [ships indexOfObject:@(shipId)];
		shipDeckNumber = index / 6;
		shipDeckIndex = index % 6;
	}
	
	// 配置しようとする位置に今配置されている艦娘
	NSInteger replaceShipId = [ships[(deckNumber - 1) * 6 + shipIndex] integerValue];
	
	// 艦隊に配備
	HMKCDeck *deck = decks[deckNumber - 1];
	[deck setValue:@(shipId) forKey:[NSString stringWithFormat:@"ship_%ld", shipIndex]];
	
	// 入れ替え
	if(alreadyInFleet && shipId != -1) {
		HMKCDeck *deck = decks[shipDeckNumber];
		[deck setValue:@(replaceShipId) forKey:[NSString stringWithFormat:@"ship_%ld", shipDeckIndex]];
	}
	
	[self packFleet];
	self.store = nil;
	
	//
	if(alreadyInFleet && shipId == -1) {
		[self notifyWithType:kHMChangeHenseiRemove
				 fleetNumber:@(deckNumber)
					position:@(shipIndex)
					  shipID:@(replaceShipId)
		  replaceFleetNumber:nil
			 replacePosition:nil
			   replaceShipID:nil];
	} else if(alreadyInFleet) {
		[self notifyWithType:kHMChangeHenseiReplace
				 fleetNumber:@(deckNumber)
					position:@(shipIndex)
					  shipID:@(shipId)
		  replaceFleetNumber:@(shipDeckNumber + 1)
			 replacePosition:@(shipDeckIndex)
			   replaceShipID:@(replaceShipId)];
	} else {
		[self notifyWithType:kHMChangeHenseiAppend
				 fleetNumber:@(deckNumber)
					position:@(shipIndex)
					  shipID:@(shipId)
		  replaceFleetNumber:nil
			 replacePosition:nil
			   replaceShipID:nil];
	}
}

- (void)notifyWithType:(HMChangeHenseiType)type
		   fleetNumber:(NSNumber *)fleetNumber
			  position:(NSNumber *)position
				shipID:(NSNumber *)shipID
	replaceFleetNumber:(NSNumber *)replaceFleetNumber
	   replacePosition:(NSNumber *)replacePosition
		 replaceShipID:(NSNumber *)replaceShipID
{
	HMChangeHenseiNotificationUserInfo *info = [HMChangeHenseiNotificationUserInfo new];
	info.type = type;
	info.fleetNumber = fleetNumber;
	info.position = position;
	info.shipID = shipID;
	info.replaceFleetNumber = replaceFleetNumber;
	info.replacePosition = replacePosition;
	info.replaceShipID = replaceShipID;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:HMChangeHenseiNotification
														object:self
													  userInfo:@{HMChangeHenseiUserInfoKey: info}];
}
@end
