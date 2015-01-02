//
//  HMChangeHenseiCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/06/15.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMChangeHenseiCommand.h"

#import "KCD-Swift.h"

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
	NSArray *decks = [self.store objectsWithEntityName:@"Deck"
									   sortDescriptors:@[sortDescriptor]
											 predicate:nil
												 error:&error];
	// TODO: error handling
	
	NSMutableArray *ships = [NSMutableArray new];
	for(id deck in decks) {
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
	NSArray *decks = [self.store objectsWithEntityName:@"Deck"
											 predicate:nil
												 error:&error];
	// TODO: error handling
	
	for(id deck in decks) {
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
	NSArray *decks = [self.store objectsWithEntityName:@"Deck"
												 error:&error
									   predicateFormat:@"id = %ld", deckNumber];
	// TODO: error handling
	id deck = decks[0];
	
	for(NSInteger i = 1; i < 6; i++) {
		[deck setValue:@(-1) forKey:[NSString stringWithFormat:@"ship_%ld", i]];
	}
}

- (void)execute
{
	NSInteger deckNumber = [[self.arguments valueForKey:@"api_id"] integerValue];
	NSInteger shipId = [[self.arguments valueForKey:@"api_ship_id"] integerValue];
	NSInteger shipIndex = [[self.arguments valueForKey:@"api_ship_idx"] integerValue];
	
	if(shipId < -1) {
		[self excludeShipsWithoutFlag];
		return;
	}
	
	NSError *error = nil;
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
	NSArray *decks = [self.store objectsWithEntityName:@"Deck"
									   sortDescriptors:@[sortDescriptor]
											 predicate:nil
												 error:&error];
	// TODO: error handling
	
	NSMutableArray *ships = [NSMutableArray new];
	for(id deck in decks) {
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
	
	NSInteger replaceShipId = [ships[(deckNumber - 1) * 6 + shipIndex] integerValue];
	
	// 艦隊に配備
	id deck = decks[deckNumber - 1];
	[deck setValue:@(shipId) forKey:[NSString stringWithFormat:@"ship_%ld", shipIndex]];
	
	// 入れ替え
	if(alreadyInFleet && shipId != -1) {
		id deck = decks[shipDeckNumber];
		[deck setValue:@(replaceShipId) forKey:[NSString stringWithFormat:@"ship_%ld", shipDeckIndex]];
	}
	
	[self packFleet];
}
@end
