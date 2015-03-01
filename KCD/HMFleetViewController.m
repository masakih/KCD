//
//  HMFleetViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2015/03/01.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMFleetViewController.h"
#import "HMShipDetailViewController.h"

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


@property (nonatomic, weak) IBOutlet NSTextField *fleetID;
- (IBAction)changeFleet:(id)sender;
@end

@implementation HMFleetViewController
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
		[self setValue:detail forKey:detailKey];
		NSView *view = [self valueForKey:placeholderKey];
		
		[detail.view setFrame:[view frame]];
		[detail.view setAutoresizingMask:[view autoresizingMask]];
		[[view superview] replaceSubview:view with:detail.view];
	}
}
- (void)setFleet:(HMKCDeck *)fleet
{
	self.representedObject = fleet;
	
	
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	for(NSInteger i = 1; i < 7; i++) {
		NSString *shipID = [self.fleet valueForKey:[NSString stringWithFormat:@"ship_%ld", i - 1]];
		
		HMKCShipObject *ship = nil;
		NSArray *array = [store objectsWithEntityName:@"Ship"
												error:NULL
									  predicateFormat:@"id = %@", shipID];
		if(array.count != 0) {
			ship = array[0];
		}
		HMShipDetailViewController *detail = [self valueForKey:[NSString stringWithFormat:@"detail%02ld", i]];
		detail.ship = ship;
	}
}
- (HMKCDeck *)fleet
{
	return self.representedObject;
}

- (IBAction)changeFleet:(id)sender
{
	NSInteger fleetID = self.fleetID.integerValue;
	
	HMServerDataStore *store = [HMServerDataStore defaultManager];
	
	NSArray *array = [store objectsWithEntityName:@"Deck"
											error:NULL
								  predicateFormat:@"id = %ld", fleetID];
	if(array.count == 0) {
		return;
	}
	
	self.fleet = array[0];
}

@end
