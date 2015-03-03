//
//  HMFleetViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2015/03/01.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMFleetViewController.h"
#import "HMShipDetailViewController.h"

#import "HMKCShipObject+Extensions.h"
#import "HMKCDeck+Extension.h"

#import "HMServerDataStore.h"

@interface HMFleetViewController ()

@property (nonatomic, weak) IBOutlet NSView *placeholder01;
@property (nonatomic, weak) IBOutlet NSView *placeholder02;
@property (nonatomic, weak) IBOutlet NSView *placeholder03;
@property (nonatomic, weak) IBOutlet NSView *placeholder04;
@property (nonatomic, weak) IBOutlet NSView *placeholder05;
@property (nonatomic, weak) IBOutlet NSView *placeholder06;

@property (strong) HMShipDetailViewController *detail01;
@property (strong) HMShipDetailViewController *detail02;
@property (strong) HMShipDetailViewController *detail03;
@property (strong) HMShipDetailViewController *detail04;
@property (strong) HMShipDetailViewController *detail05;
@property (strong) HMShipDetailViewController *detail06;

@end

@implementation HMFleetViewController
@synthesize fleetNumber = _fleetNumber;

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	return self;
}

- (void)awakeFromNib {
	
	for(NSInteger i = 1; i < 7; i++) {
		NSString *detailKey = [NSString stringWithFormat:@"detail%02ld", i];
		NSString *placeholderKey = [NSString stringWithFormat:@"placeholder%02ld", i];
		HMShipDetailViewController *detail = [HMShipDetailViewController new];
		detail.title = [NSString stringWithFormat:@"%ld", i];
		[self setValue:detail forKey:detailKey];
		NSView *view = [self valueForKey:placeholderKey];
		
		[detail.view setFrame:[view frame]];
		[detail.view setAutoresizingMask:[view autoresizingMask]];
		[[view superview] replaceSubview:view with:detail.view];
	}
	
	self.fleetNumber = 1;
}

- (void)setShipID:(NSInteger)shipId toDetail:(HMShipDetailViewController *)detail
{
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	NSError *error = nil;
	HMKCShipObject *ship = nil;
	NSArray *array = [store objectsWithEntityName:@"Ship"
											error:&error
								  predicateFormat:@"id = %ld", shipId];
	if(error) {
		NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
	}
	if(array.count != 0) {
		ship = array[0];
	}
	detail.ship = ship;
}
- (void)setFleet:(HMKCDeck *)fleet
{
	for(NSInteger i = 0; i < 6; i++) {
		[self.representedObject removeObserver:self
									forKeyPath:[NSString stringWithFormat:@"ship_%ld", i]];
	}
	
	for(NSInteger i = 0; i < 6; i++) {
		[fleet addObserver:self
				forKeyPath:[NSString stringWithFormat:@"ship_%ld", i]
				   options:0
				   context:NULL];
	}
	
	self.representedObject = fleet;
	self.title = fleet.name;
	
	for(NSInteger i = 1; i < 7; i++) {
		NSString *shipID = [self.fleet valueForKey:[NSString stringWithFormat:@"ship_%ld", i - 1]];
		HMShipDetailViewController *detail = [self valueForKey:[NSString stringWithFormat:@"detail%02ld", i]];
		[self setShipID:shipID.integerValue toDetail:detail];
	}
}
- (HMKCDeck *)fleet
{
	return self.representedObject;
}

- (void)setFleetNumber:(NSInteger)fleetNumber
{
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	NSError *error = nil;
	NSArray *array = [store objectsWithEntityName:@"Deck"
											error:NULL
								  predicateFormat:@"id = %ld", fleetNumber];
	if(error) {
		NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
		return;
	}
	if(array.count == 0) {
		return;
	}
	
	self.fleet = array[0];
	_fleetNumber = fleetNumber;
}
- (NSInteger)fleetNumber
{
	return _fleetNumber;
}

+ (NSSet *)keyPathsForValuesAffectingTotalSakuteki
{
	return [NSSet setWithObjects:
			@"detail01.ship.sakuteki_0",
			@"detail02.ship.sakuteki_0",
			@"detail03.ship.sakuteki_0",
			@"detail04.ship.sakuteki_0",
			@"detail05.ship.sakuteki_0",
			@"detail06.ship.sakuteki_0",
			nil];
}
- (NSNumber *)totalSakuteki
{
	NSInteger total = 0;
	for(NSInteger i = 1; i < 7; i++) {
		HMShipDetailViewController *detail = [self valueForKey:[NSString stringWithFormat:@"detail%02ld", i]];
		HMKCShipObject *ship = detail.ship;
		total += ship.sakuteki_0.integerValue;
	}
	return @(total);
}

+ (NSSet *)keyPathsForValuesAffectingTotalSeiku
{
	return [NSSet setWithObjects:
			@"detail01.ship.seiku",
			@"detail02.ship.seiku",
			@"detail03.ship.seiku",
			@"detail04.ship.seiku",
			@"detail05.ship.seiku",
			@"detail06.ship.seiku",
			nil];
}
- (NSNumber *)totalSeiku
{
	NSInteger total = 0;
	for(NSInteger i = 1; i < 7; i++) {
		HMShipDetailViewController *detail = [self valueForKey:[NSString stringWithFormat:@"detail%02ld", i]];
		HMKCShipObject *ship = detail.ship;
		total += ship.seiku.integerValue;
	}
	return @(total);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"ship_0"]) {
		[self setShipID:[[object valueForKey:keyPath] integerValue] toDetail:self.detail01];
		return;
	}
	if([keyPath isEqualToString:@"ship_1"]) {
		[self setShipID:[[object valueForKey:keyPath] integerValue] toDetail:self.detail02];
		return;
	}
	if([keyPath isEqualToString:@"ship_2"]) {
		[self setShipID:[[object valueForKey:keyPath] integerValue] toDetail:self.detail03];
		return;
	}
	if([keyPath isEqualToString:@"ship_3"]) {
		[self setShipID:[[object valueForKey:keyPath] integerValue] toDetail:self.detail04];
		return;
	}
	if([keyPath isEqualToString:@"ship_4"]) {
		[self setShipID:[[object valueForKey:keyPath] integerValue] toDetail:self.detail05];
		return;
	}
	if([keyPath isEqualToString:@"ship_5"]) {
		[self setShipID:[[object valueForKey:keyPath] integerValue] toDetail:self.detail06];
		return;
	}
	
	return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
