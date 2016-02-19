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

#import "HMAppDelegate.h"

#import "HMKCShipObject+Extensions.h"
#import "HMKCDeck+Extension.h"

#import "HMServerDataStore.h"

#import "HMAnchorageRepairManager.h"


const NSInteger maxFleetNumber = 4;

@interface HMFleetViewController ()

@property (readwrite) HMFleetViewType type;

@property (strong) HMFleet *fleet;
@property (strong) NSObjectController *fleetController;

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


@property (strong) NSNumber *totalSakuteki;
@property (strong) NSNumber *totalSeiku;
@property (strong) NSNumber *totalCalclatedSeiku;
@property (strong) NSNumber *totalLevel;
@property (strong) NSNumber *totalDrums;


@property (strong) NSArray *anchorageRepairHolder;
@property (strong) HMAnchorageRepairManager *anchorageRepair;
@property (readonly) NSNumber *repairTime;
@property (readonly) NSNumber *repairableShipCount;

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
		
		[_fleetController addObserver:self forKeyPath:@"selection.ships" options:0 context:NULL];
		[_fleetController addObserver:self forKeyPath:@"selection.name" options:0 context:NULL];
		
		[self bind:@"totalSakuteki" toObject:_fleetController withKeyPath:@"selection.totalSakuteki" options:nil];
		[self bind:@"totalSeiku" toObject:_fleetController withKeyPath:@"selection.totalSeiku" options:nil];
		[self bind:@"totalCalclatedSeiku" toObject:_fleetController withKeyPath:@"selection.totalCalclatedSeiku" options:nil];
		[self bind:@"totalLevel" toObject:_fleetController withKeyPath:@"selection.totalLevel" options:nil];
		[self bind:@"totalDrums" toObject:_fleetController withKeyPath:@"selection.totalDrums" options:nil];
		
		[self buildAnchorageRepairHolder];
		
		[self loadView];
	}
	return self;
}
+ (instancetype)viewControlerWithViewType:(HMFleetViewType)type
{
	return [[self alloc] initWithViewType:type];
}

- (void)dealloc
{
	for(NSString *key in self.shipKeys) {
		[self.representedObject removeObserver:self
									forKeyPath:key];
	}
	
	[_fleetController unbind:@"content"];
	
	[_fleetController removeObserver:self forKeyPath:@"selection.ships"];
	[_fleetController removeObserver:self forKeyPath:@"selection.name"];
	
	[self unbind:@"totalSakuteki"];
	[self unbind:@"totalSeiku"];
	[self unbind:@"totalCalclatedSeiku"];
	[self unbind:@"totalLevel"];
	[self unbind:@"totalDrums"];
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
	for(NSUInteger i = 0; i < self.details.count; i++) {
		self.details[i].ship = self.fleet[i];
	}
}

- (HMFleet *)fleet
{
	return self.representedObject;
}
- (void)setFleet:(HMFleet *)fleet
{
	self.representedObject = fleet;
	self.title = fleet.name;
	[self setupShips];
}

- (void)setFleetNumber:(NSInteger)fleetNumber
{
	self.fleet = [HMFleet fleetWithNumber:@(fleetNumber)];
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
	if([keyPath isEqualToString:@"selection.ships"]) {
		[self setupShips];
		return;
	}
	if([keyPath isEqualToString:@"selection.name"]) {
		self.title = self.fleet.name;
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
	NSMutableArray<HMAnchorageRepairManager *> *anchorageRepairs = [NSMutableArray new];
	for(NSInteger i = 1; i <= 4; i++) {
		HMFleet *fleet = [HMFleet fleetWithNumber:@(i)];
		HMAnchorageRepairManager *anchorageRepair = [HMAnchorageRepairManager anchorageRepairManagerWithFleet:fleet];
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
	return [NSSet setWithObjects:
			@"fleet",
			@"anchorageRepair.repairTime", @"anchorageRepair", nil];
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
			@"fleet",
			@"anchorageRepair.repairableShipCount", @"anchorageRepair",
			nil];
}
- (NSNumber *)repairableShipCount
{
	return self.anchorageRepair.repairableShipCount;
}

@end
