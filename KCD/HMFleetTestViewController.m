//
//  HMFleetTestViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2016/02/11.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMFleetTestViewController.h"

#import "HMFleet.h"

@interface HMFleetTestViewController ()
@property (strong) NSArray<HMFleet *> *fleets;

@property (nonatomic, strong) IBOutlet NSObjectController *shipController;
@property (nonatomic, weak) IBOutlet NSTextField *slot00Field;
@property (nonatomic, weak) IBOutlet NSTextField *slot01Field;
@property (nonatomic, weak) IBOutlet NSTextField *slot02Field;
@property (nonatomic, weak) IBOutlet NSTextField *slot03Field;

@end

@implementation HMFleetTestViewController

+ (instancetype)new
{
	HMFleetTestViewController *result = [[self alloc] initWithNibName:NSStringFromClass([self class])
															   bundle:nil];
	
	NSMutableArray<HMFleet *> *fleets = [NSMutableArray arrayWithCapacity:4];
	for(NSInteger i = 1; i < 5; i++) {
		[fleets addObject:[HMFleet fleetWithNumber:@(i)]];
	}
	result.fleets = fleets;
	
	return result;
}

- (void)awakeFromNib
{
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
}
@end
