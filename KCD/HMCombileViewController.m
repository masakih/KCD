//
//  HMCombileViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2015/11/20.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMCombileViewController.h"

#import "HMFleetViewController.h"


@interface HMCombileViewController ()

@property (nonatomic, strong) HMFleetViewController* fleet1;
@property (nonatomic, strong) HMFleetViewController* fleet2;

@property (nonatomic, weak) IBOutlet NSView *placeholder1;
@property (nonatomic, weak) IBOutlet NSView *placeholder2;

@end

@implementation HMCombileViewController

- (void)awakeFromNib
{
	self.fleet1 = [HMFleetViewController viewControlerWithViewType:miniVierticalType];
	[self.fleet1.view setFrame:[self.placeholder1 frame]];
	[self.fleet1.view setAutoresizingMask:[self.placeholder1 autoresizingMask]];
	[[self.placeholder1 superview] replaceSubview:self.placeholder1 with:self.fleet1.view];
	self.fleet1.fleetNumber = 1;
	
	self.fleet2 = [HMFleetViewController viewControlerWithViewType:miniVierticalType];
	[self.fleet2.view setFrame:[self.placeholder2 frame]];
	[self.fleet2.view setAutoresizingMask:[self.placeholder2 autoresizingMask]];
	[[self.placeholder2 superview] replaceSubview:self.placeholder2 with:self.fleet2.view];
	self.fleet2.fleetNumber = 2;
}

@end
