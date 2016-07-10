//
//  HMFleetViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2015/03/01.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMFleetViewController.h"
#import "HMShipDetailViewController.h"

#import "HMFleet.h"
#import "HMFleetManager.h"

#import "HMAppDelegate.h"

#import "HMKCShipObject+Extensions.h"
#import "HMKCDeck+Extension.h"
#import "HMKCMasterShipObject.h"
#import "HMKCMasterSType.h"

#import "HMServerDataStore.h"

#import "HMAnchorageRepairManager.h"


const NSInteger maxFleetNumber = 4;

@interface HMFleetViewController ()

@property (readwrite) HMFleetViewType type;

@property (strong) HMKCDeck *fleet;
@property (strong) NSObjectController *fleetController;

@property (nonatomic, strong) NSArray<HMKCShipObject *> *ships;

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
@property (strong) NSArray<HMShipDetailViewController *> *details;

@property (readonly) NSArray *shipKeys;


@property (strong) HMAnchorageRepairManager *anchorageRepair;
@property (readonly) NSNumber *repairTime;
@property (readonly) BOOL repairable;

@end

@implementation HMFleetViewController
@synthesize fleetNumber = _fleetNumber;
@synthesize shipOrder = _shipOrder;

- (instancetype)initWithViewType:(HMFleetViewType)type
{
	NSString *nibName = nil;
	switch (type) {
		case detailViewType:
			nibName = NSStringFromClass([self class]);
			break;
		case minimumViewType:
			nibName = @"HMFleetMinimumViewController";
			break;
		case miniVierticalType:
			nibName = @"HMVerticalFleetViewController";
			break;
	}
	assert(nibName);
	
	self = [super initWithNibName:nibName bundle:nil];
	if(self) {
		_type = type;
		
		_fleetController = [NSObjectController new];
		[_fleetController bind:@"content" toObject:self withKeyPath:@"fleet" options:nil];
		
		[_fleetController addObserver:self forKeyPath:@"selection.name" options:0 context:NULL];
		
		for(NSString *key in self.shipKeys) {
			NSString *keyPath = [NSString stringWithFormat:@"selection.%@", key];
			[_fleetController addObserver:self forKeyPath:keyPath options:0 context:(__bridge void * _Nullable)(key)];
		}
		
		[self buildAnchorageRepairHolder];
		
		[self loadView];
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFleet:) name:HMFleetManagerCompletePrepareFleetNotification object:nil];
	}
	return self;
}
+ (instancetype)viewControlerWithViewType:(HMFleetViewType)type
{
	return [[self alloc] initWithViewType:type];
}

- (void)dealloc
{
	[_fleetController unbind:@"content"];
	
	[_fleetController removeObserver:self forKeyPath:@"selection.name"];
	
	for(NSString *key in self.shipKeys) {
		NSString *keyPath = [NSString stringWithFormat:@"selection.%@", key];
		[_fleetController removeObserver:self forKeyPath:keyPath];
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
	HMShipDetailViewType viewType;
	switch(self.type) {
		case detailViewType:
			viewType = full;
			break;
		case minimumViewType:
			viewType = medium;
			break;
		case miniVierticalType:
			viewType = minimum;
			break;
	}
	NSMutableArray *details = [NSMutableArray new];
	NSArray *detailKeys = @[@"detail01", @"detail02", @"detail03", @"detail04", @"detail05", @"detail06"];
	[detailKeys enumerateObjectsUsingBlock:^(id detailKey, NSUInteger idx, BOOL *stop) {
		HMShipDetailViewController *detail = [HMShipDetailViewController viewControllerWithType:viewType];
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
}

- (NSArray *)shipKeys
{
	static NSArray *shipKeys = nil;
	if(shipKeys) return shipKeys;
	
	shipKeys = @[@"ship_0", @"ship_1", @"ship_2", @"ship_3", @"ship_4", @"ship_5"];
	return shipKeys;
}

- (void)setupShips
{
	NSMutableArray<HMKCShipObject *> *array = [NSMutableArray array];
	for(NSUInteger i = 0; i < 6; i++) {
		HMKCShipObject *ship = self.fleet[i];
		if(ship) {
			[array addObject:ship];
		}
	}
	
	if([_ships isEqualToArray:array]) {
		return;
	}
	
	for(NSUInteger i = 0; i < 6; i++) {
		if(i < array.count) {
			self.details[i].ship = array[i];
		} else {
			self.details[i].ship = nil;
		}
	}
	
	self.ships = array;
	
	
	[self willChangeValueForKey:@"totalSakuteki"];
	[self didChangeValueForKey:@"totalSakuteki"];
	[self willChangeValueForKey:@"totalSeiku"];
	[self didChangeValueForKey:@"totalSeiku"];
	[self willChangeValueForKey:@"totalCalclatedSeiku"];
	[self didChangeValueForKey:@"totalCalclatedSeiku"];
	[self willChangeValueForKey:@"totalLevel"];
	[self didChangeValueForKey:@"totalLevel"];
	[self willChangeValueForKey:@"totalDrums"];
	[self didChangeValueForKey:@"totalDrums"];
}

-(NSArray<NSString *> *)shipObserveKeys
{
	static NSArray *array = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		array = @[@"sakuteki_0", @"seiku", @"lv", @"totalDrums"];
	});
	return  array;
}

- (void)setShips:(NSArray<HMKCShipObject *> *)ships
{
	for(HMKCShipObject *ship in _ships) {
		for(NSString *key in self.shipObserveKeys) {
			[ship removeObserver:self forKeyPath:key];
		}
	}
	
	_ships = ships;
	
	for(HMKCShipObject *ship in _ships) {
		for(NSString *key in self.shipObserveKeys) {
			[ship addObserver:self forKeyPath:key options:0 context:(__bridge void * _Nullable)(_ships)];
		}
	}
}

- (HMKCDeck *)fleet
{
	return self.representedObject;
}
- (void)setFleet:(HMKCDeck *)fleet
{
	self.representedObject = fleet;
	self.title = fleet.name;
	[self setupShips];
}

- (void)setFleetNumber:(NSInteger)fleetNumber
{
	_fleetNumber = fleetNumber;
	
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	NSArray<HMKCDeck *> *decks = [store objectsWithEntityName:@"Deck"
														error:NULL
											  predicateFormat:@"id = %ld", fleetNumber];
	if(decks.count == 0) {
		NSLog(@"Deck is Brocken");
		return;
	}
	self.fleet = decks[0];
	
}
- (NSInteger)fleetNumber
{
	return _fleetNumber;
}

- (void)updateFleet:(NSNotification *)notification
{
	[self setFleetNumber:_fleetNumber];
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
		case miniVierticalType:
			//
			break;
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
		case miniVierticalType:
			//
			break;
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	id contextObject = (__bridge id)(context);
	
	if([self.shipKeys containsObject:contextObject]) {
		[self setupShips];
		return;
	}
	if([keyPath isEqualToString:@"selection.name"]) {
		self.title = self.fleet.name;
		return;
	}
	
	if(contextObject == _ships) {
		if([keyPath isEqualToString:@"sakuteki_0"]) {
			[self willChangeValueForKey:@"totalSakuteki"];
			[self didChangeValueForKey:@"totalSakuteki"];
		}
		if([keyPath isEqualToString:@"seiku"]) {
			[self willChangeValueForKey:@"totalSeiku"];
			[self didChangeValueForKey:@"totalSeiku"];
			
			[self willChangeValueForKey:@"totalCalclatedSeiku"];
			[self didChangeValueForKey:@"totalCalclatedSeiku"];
		}
		if([keyPath isEqualToString:@"lv"]) {
			[self willChangeValueForKey:@"totalLevel"];
			[self didChangeValueForKey:@"totalLevel"];
		}
		if([keyPath isEqualToString:@"totalDrums"]) {
			[self willChangeValueForKey:@"totalDrums"];
			[self didChangeValueForKey:@"totalDrums"];
		}
		
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


- (NSNumber *)totalSakuteki
{
	NSInteger total = 0;
	for(HMKCShipObject *ship in self.ships) {
		total += ship.sakuteki_0.integerValue;
	}
	return @(total);
}

- (NSNumber *)totalSeiku
{
	NSInteger total = 0;
	for(HMKCShipObject *ship in self.ships) {
		total += ship.seiku.integerValue;
	}
	return @(total);
}

- (NSNumber *)totalCalclatedSeiku
{
	NSInteger total = 0;
	for(HMKCShipObject *ship in self.ships) {
		total += ship.totalSeiku.integerValue;
	}
	return @(total);
}

- (NSNumber *)totalLevel
{
	NSInteger total = 0;
	for(HMKCShipObject *ship in self.ships) {
		total += ship.lv.integerValue;
	}
	return @(total);
}

- (NSNumber *)totalDrums
{
	NSInteger total = 0;
	for(HMKCShipObject *ship in self.ships) {
		total += ship.totalDrums.integerValue;
	}
	return @(total);
}


- (void)buildAnchorageRepairHolder
{
	self.anchorageRepair = [HMAnchorageRepairManager defaultManager];
	
	HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
	[appDelegate addCounterUpdateBlock:^{
		[self willChangeValueForKey:@"repairTime"];
		[self didChangeValueForKey:@"repairTime"];
	}];
}
+ (NSSet *)keyPathsForValuesAffectingRepairTime
{
	return [NSSet setWithObjects:
			@"fleet",
			@"anchorageRepair.repairTime", nil];
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

- (NSArray *)repairShipIds
{
	return @[@(19)];
}

+ (NSSet *)keyPathsForValuesAffectingRepairable
{
	return [NSSet setWithObjects:
			@"fleet",
			@"ships",
			nil];
}
- (BOOL)repairable
{
	HMKCShipObject *flagShip = self.fleet[0];
	HMKCMasterShipObject *flagShipMaster = flagShip.master_ship;
	HMKCMasterSType *stype = flagShipMaster.stype;
	NSNumber *stypeId = stype.id;
	BOOL result = [self.repairShipIds containsObject:stypeId];
	
	return result;
}
@end
