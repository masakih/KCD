//
//  HMShipDetailViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2015/02/28.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMShipDetailViewController.h"
#import "HMSuppliesView.h"

#import "HMServerDataStore.h"
#import "HMKCShipObject+Extensions.h"

#import "HMGuardEscapedView.h"
#import "HMGuardShelterCommand.h"
#import "HMDamageView.h"


@interface HMShipDetailViewController ()

@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) HMShipDetailViewType type;

@property (nonatomic, weak) IBOutlet HMSuppliesView *supply;
@property (nonatomic, weak) IBOutlet HMGuardEscapedView *guardEscapedView;
@property (nonatomic, weak) IBOutlet HMDamageView *damageView;

@property (nonatomic, strong) IBOutlet NSObjectController *shipController;
@property (nonatomic, weak) IBOutlet NSTextField *slot00Field;
@property (nonatomic, weak) IBOutlet NSTextField *slot01Field;
@property (nonatomic, weak) IBOutlet NSTextField *slot02Field;
@property (nonatomic, weak) IBOutlet NSTextField *slot03Field;

@end

@implementation HMShipDetailViewController

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if(self) {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(updateStatus:)
				   name:HMGuardShelterCommandDidUpdateGuardExcapeNotification
				 object:nil];
	}
	return self;
}

- (instancetype)initWithType:(HMShipDetailViewType)type
{
	NSString *nibName = nil;
	switch(type) {
		case full:
			nibName = @"HMShipDetailViewController";
			break;
		case medium:
			nibName = @"HMMediumShipViewController";
			break;
		case minimum:
			nibName = @"HMMediumShipViewController";
			break;
	}
	assert(nibName);
	
	self = [super initWithNibName:nibName bundle:nil];
	if(self) {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(updateStatus:)
				   name:HMGuardShelterCommandDidUpdateGuardExcapeNotification
				 object:nil];
		_type = type;
	}
	return self;
}
+ (instancetype)viewControllerWithType:(HMShipDetailViewType)type
{
	return [[self alloc] initWithType:type];
}
- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[self.damageView unbind:@"damageType"];
	[self.supply unbind:@"shipStatus"];
}

- (void)updateStatus:(NSNotification *)notification
{
	NSNumber *escaped = self.ship.guardEscaped;
	self.guardEscaped = [escaped boolValue];
}


- (void)awakeFromNib
{
	[self.damageView setFrameOrigin:NSZeroPoint];
	[self.view addSubview:self.damageView];
	[self.damageView bind:@"damageType"
				 toObject:self.shipController
			  withKeyPath:@"selection.status"
				  options:@{
							NSRaisesForNotApplicableKeysBindingOption : @YES,
							}];
	
	[self.supply bind:@"shipStatus"
			 toObject:self.shipController
		  withKeyPath:@"selection.self"
			  options:nil];
	
	[self.guardEscapedView setFrameOrigin:NSZeroPoint];
	[self.view addSubview:self.guardEscapedView];
	if(self.type == medium || self.type == minimum) {
		self.guardEscapedView.controlSize = NSMiniControlSize;
	}
	
	[self.slot00Field bind:@"slotItemID"
				  toObject:self.shipController
			   withKeyPath:@"selection.slot_0"
				   options:nil];
	[self.slot01Field bind:@"slotItemID"
				  toObject:self.shipController
			   withKeyPath:@"selection.slot_1"
				   options:nil];
	[self.slot02Field bind:@"slotItemID"
				  toObject:self.shipController
			   withKeyPath:@"selection.slot_2"
				   options:nil];
	[self.slot03Field bind:@"slotItemID"
				  toObject:self.shipController
			   withKeyPath:@"selection.slot_3"
				   options:nil];
	
	
	[NSPredicate predicateWithFormat:@"id = %@", @(-1)];
}


- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}

- (NSPredicate *)fetchPredicateWithShipID:(NSNumber *)shipID
{
	NSPredicate *p = [NSPredicate predicateWithFormat:@"id = %@", shipID];
	return p;
}

- (void)setShip:(HMKCShipObject *)ship
{
	self.shipController.fetchPredicate = [self fetchPredicateWithShipID:ship.id];
	[self performSelector:@selector(updateStatus:)
			   withObject:nil
			   afterDelay:0.0];
}
- (HMKCShipObject *)ship
{
	return self.shipController.content;
}

- (void)setGuardEscaped:(BOOL)guardEscaped
{
	self.guardEscapedView.hidden = !guardEscaped;
	_guardEscaped = guardEscaped;
}

@end
