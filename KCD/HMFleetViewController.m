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

#import "HMAppDelegate.h"

#import "HMKCShipObject+Extensions.h"
#import "HMKCDeck+Extension.h"

#import "HMServerDataStore.h"

#import "HMAnchorageRepairManager.h"


const NSInteger maxFleetNumber = 4;

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
@property (strong) NSArray *details;

@property (readonly) NSArray *shipKeys;


@property (strong) NSArray *anchorageRepairHolder;
@property (strong) HMAnchorageRepairManager *anchorageRepair;
@property (readonly) NSNumber *repairTime;
@property (readonly) NSNumber *repairableShipCount;

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
		
		[self buildAnchorageRepairHolder];
	}
	return self;
}

- (void)dealloc
{
	for(NSString *key in self.shipKeys) {
		[self.representedObject removeObserver:self
									forKeyPath:key];
	}
}

- (void)awakeFromNib
{
	NSMutableArray *details = [NSMutableArray new];
	NSArray *detailKeys = @[@"detail01", @"detail02", @"detail03", @"detail04", @"detail05", @"detail06"];
	[detailKeys enumerateObjectsUsingBlock:^(id detailKey, NSUInteger idx, BOOL *stop) {
		HMShipDetailViewController *detail = [self.shipViewClass new];
		detail.title = [NSString stringWithFormat:@"%ld", idx + 1];
		[self setValue:detail forKey:detailKey];
		
		[details addObject:detail];
	}];
	self.details = details;
	
	NSArray *placeholderKeys = @[@"placeholder01", @"placeholder02", @"placeholder03", @"placeholder04", @"placeholder05", @"placeholder06"];
	[placeholderKeys enumerateObjectsUsingBlock:^(id placeholderKey, NSUInteger idx, BOOL *stop) {
		NSView *view = [self valueForKey:placeholderKey];
		HMShipDetailViewController *detail = self.details[idx];
		[detail.view setFrame:[view frame]];
		[detail.view setAutoresizingMask:[view autoresizingMask]];
		[[view superview] replaceSubview:view with:detail.view];
	}];
	
	self.fleetNumber = 1;
	
	self.detail04.guardEscaped = YES;
}

- (NSArray *)shipKeys
{
	static NSArray *shipKeys = nil;
	if(shipKeys) return shipKeys;
	
	shipKeys = @[@"ship_0", @"ship_1", @"ship_2", @"ship_3", @"ship_4", @"ship_5"];
	return shipKeys;
}

- (void)setShipOfViewForKey:(NSString *)key
{
	NSUInteger index = [self.shipKeys indexOfObject:key];
	if(index != NSNotFound) {
		NSUInteger shipID = [[self.fleet valueForKey:key] integerValue];
		[self setShipID:shipID
			   toDetail:self.details[index]];
	}
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
	
	[self willChangeValueForKey:@"repairableShipCount"];
	[self didChangeValueForKey:@"repairableShipCount"];
}
- (void)setFleet:(HMKCDeck *)fleet
{
	for(NSString *key in self.shipKeys) {
		[self.representedObject removeObserver:self
									forKeyPath:key];
		
		[fleet addObserver:self
				forKeyPath:key
				   options:0
				   context:NULL];
	}
	
	self.representedObject = fleet;
	self.title = fleet.name;
	
	for(NSString *key in self.shipKeys) {
		[self setShipOfViewForKey:key];
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
	
	self.anchorageRepair = self.anchorageRepairHolder[fleetNumber - 1];
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
			return HMFleetViewController.detailViewHeight;
		case minimumViewType:
			return HMFleetViewController.oldStyleFleetViewHeight;
	}
	return 0;
}
- (CGFloat)upsideHeight
{
	switch(self.type) {
		case detailViewType:
			return 159;
		case minimumViewType:
			return HMFleetViewController.oldStyleFleetViewHeight;
	}
	return 0;
}

+ (CGFloat)oldStyleFleetViewHeight
{
	return 128;
}
+ (CGFloat)detailViewHeight
{
	return 288;
}
+ (CGFloat)heightDifference
{
	return self.detailViewHeight - self.oldStyleFleetViewHeight;
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
	for(HMShipDetailViewController *detail in self.details) {
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
	for(HMShipDetailViewController *detail in self.details) {
		HMKCShipObject *ship = detail.ship;
		total += ship.seiku.integerValue;
	}
	return @(total);
}
+ (NSSet *)keyPathsForValuesAffectingTotalCalclatedSeiku
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
- (NSNumber *)totalCalclatedSeiku
{
	NSInteger total = 0;
	for(HMShipDetailViewController *detail in self.details) {
		HMKCShipObject *ship = detail.ship;
		total += ship.seiku.integerValue;
		total += ship.extraSeiku.integerValue;
	}
	return @(total);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([self.shipKeys containsObject:keyPath]) {
		[self setShipOfViewForKey:keyPath];
		return;
	}
	
	return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (IBAction)selectNextFleet:(id)sender
{
	NSInteger next = self.fleetNumber + 1;
	self.fleetNumber = next <= maxFleetNumber ? next : 1;
}
- (IBAction)selectPreviousFleet:(id)sender
{
	NSInteger prev = self.fleetNumber - 1;
	self.fleetNumber = prev > 0 ? prev : 4;
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


- (void)buildAnchorageRepairHolder
{
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	NSError *error = nil;
	NSArray *array = [store objectsWithEntityName:@"Deck"
								  sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]]
										predicate:nil
											error:&error];
	if(error) {
		NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
		return;
	}
	if(array.count == 0) {
		return;
	}
	if(array.count < 4) {
		NSBeep();
		NSLog(@"hogehoge");
		return;
	}
	NSMutableArray *anchorageRepairs = [NSMutableArray new];
	for(HMKCDeck *deck in array) {
		id anchorageRepair = [[HMAnchorageRepairManager alloc] initWithDeck:deck];
		[anchorageRepairs addObject:anchorageRepair];
	}
	self.anchorageRepairHolder = anchorageRepairs;
	
	HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
	[appDelegate addCounterUpdateBlock:^{
		[self willChangeValueForKey:@"repairTime"];
		[self didChangeValueForKey:@"repairTime"];
	}];
}
+ (NSSet *)keyPathsForValuesAffectingRepairTime
{
	return [NSSet setWithObjects:@"anchorageRepair.repairTime", @"anchorageRepair", nil];
}
- (NSNumber *)repairTime
{
	NSDate *compTimeValue = self.anchorageRepair.repairTime;
	if(!compTimeValue) return nil;
	
	NSTimeInterval compTime = [compTimeValue timeIntervalSince1970];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
	NSTimeInterval diff = compTime - [now timeIntervalSince1970];
	return @(diff + 20 * 60);
}
+ (NSSet *)keyPathsForValuesAffectingRepairableShipCount
{
	return [NSSet setWithObjects:
			@"anchorageRepair.repairableShipCount", @"anchorageRepair",
			
			
			nil];
}
- (NSNumber *)repairableShipCount
{
	return self.anchorageRepair.repairableShipCount;
}

@end
