//
//  HMFleetViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2015/03/01.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMFleetViewController.h"
#import "HMShipDetailViewController.h"
#import "HMMinimumShipViewController.h"

#import "HMKCShipObject+Extensions.h"
#import "HMKCDeck+Extension.h"

#import "HMServerDataStore.h"

@interface HMFleetViewController ()

@property (weak) Class shipViewClass;

@property (readwrite) HMFleetViewType type;

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
@synthesize shipOrder = _shipOrder;

+ (instancetype)new
{
	return [[[self class] alloc] initWithViewType:minimumViewType];
}

- (instancetype)initWithViewType:(HMFleetViewType)type
{
	Class shipViewClass = Nil;
	NSString *nibName = nil;
	switch (type) {
		case detailViewType:
			nibName = NSStringFromClass([self class]);
			shipViewClass = [HMShipDetailViewController class];
			break;
		case minimumViewType:
			nibName = @"HMFleetMinimumViewController";
			shipViewClass = [HMMinimumShipViewController class];
			break;
	}
	
	if(!nibName) {
		self = [super initWithNibName:@"" bundle:nil];
		NSLog(@"UnknownType");
		return nil;
	}
	
	self = [super initWithNibName:nibName bundle:nil];
	if(self) {
		_type = type;
		_shipViewClass = shipViewClass;
	}
	return self;
}

- (void)dealloc
{
	for(NSInteger i = 0; i < 6; i++) {
		[self.representedObject removeObserver:self
									forKeyPath:[NSString stringWithFormat:@"ship_%ld", i]];
	}
}

- (void)awakeFromNib {
	
	for(NSInteger i = 1; i < 7; i++) {
		NSString *detailKey = [NSString stringWithFormat:@"detail%02ld", i];
		NSString *placeholderKey = [NSString stringWithFormat:@"placeholder%02ld", i];
		HMShipDetailViewController *detail = [self.shipViewClass new];
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

- (void)setShipOrder:(HMFleetViewShipOrder)shipOrder
{
	if(_shipOrder == shipOrder) return;
	_shipOrder = shipOrder;
	
	switch(shipOrder) {
		case doubleLine:
			[self reorderShipToDoubleLine];
			break;
		case leftToRight:
			[self reorderShipToLeftToRight];
			break;
	}
}
- (HMFleetViewShipOrder)shipOrder
{
	return _shipOrder;
}

- (BOOL)canDivide
{
	return self.type == detailViewType;
}
- (CGFloat)normalHeight
{
	switch(self.type) {
		case detailViewType:
			return 288;
		case minimumViewType:
			return 128;
	}
	return 0;
}
- (CGFloat)upsideHeight
{
	switch(self.type) {
		case detailViewType:
			return 159;
		case minimumViewType:
			return 128;
	}
	return 0;
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

- (void)reorderShipToDoubleLine
{
	NSView *view02 = self.detail02.view;
	NSView *view03 = self.detail03.view;
	NSView *view04 = self.detail04.view;
	NSView *view05 = self.detail05.view;
	
	NSAutoresizingMaskOptions options02 = view02.autoresizingMask;
	NSAutoresizingMaskOptions options03 = view03.autoresizingMask;
	NSAutoresizingMaskOptions options04 = view04.autoresizingMask;
	NSAutoresizingMaskOptions options05 = view05.autoresizingMask;
	
	view02.autoresizingMask = options04;
	view03.autoresizingMask = options02;
	view04.autoresizingMask = options05;
	view05.autoresizingMask = options03;
	
	NSRect frame02 = view02.frame;
	NSRect frame03 = view03.frame;
	NSRect frame04 = view04.frame;
	NSRect frame05 = view05.frame;
	
	if(self.enableAnimation) {
		view02.animator.frame = frame04;
		view03.animator.frame = frame02;
		view04.animator.frame = frame05;
		view05.animator.frame = frame03;
	} else {
		view02.frame = frame04;
		view03.frame = frame02;
		view04.frame = frame05;
		view05.frame = frame03;
	}
}
- (void)reorderShipToLeftToRight
{
	NSView *view02 = self.detail02.view;
	NSView *view03 = self.detail03.view;
	NSView *view04 = self.detail04.view;
	NSView *view05 = self.detail05.view;
	
	NSAutoresizingMaskOptions options02 = view02.autoresizingMask;
	NSAutoresizingMaskOptions options03 = view03.autoresizingMask;
	NSAutoresizingMaskOptions options04 = view04.autoresizingMask;
	NSAutoresizingMaskOptions options05 = view05.autoresizingMask;
	
	view02.autoresizingMask = options03;
	view03.autoresizingMask = options05;
	view04.autoresizingMask = options02;
	view05.autoresizingMask = options04;
	
	NSRect frame02 = view02.frame;
	NSRect frame03 = view03.frame;
	NSRect frame04 = view04.frame;
	NSRect frame05 = view05.frame;
	
	if(self.enableAnimation) {
		view02.animator.frame = frame03;
		view03.animator.frame = frame05;
		view04.animator.frame = frame02;
		view05.animator.frame = frame04;
	} else {
		view02.frame = frame03;
		view03.frame = frame05;
		view04.frame = frame02;
		view05.frame = frame04;
	}
}

@end
