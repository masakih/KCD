//
//  HMDeckViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/04/12.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMDeckViewController.h"

#import "HMFleetInformation.h"

#import "HMServerDataStore.h"

#import "HMSuppliesView.h"

@interface HMDeckViewController ()

@property (strong) HMFleetInformation *fleetInfo;

@property (nonatomic, weak) IBOutlet HMSuppliesView *supplies1;
@property (nonatomic, weak) IBOutlet HMSuppliesView *supplies2;
@property (nonatomic, weak) IBOutlet HMSuppliesView *supplies3;
@property (nonatomic, weak) IBOutlet HMSuppliesView *supplies4;
@property (nonatomic, weak) IBOutlet HMSuppliesView *supplies5;
@property (nonatomic, weak) IBOutlet HMSuppliesView *supplies6;
@end

@implementation HMDeckViewController
@synthesize selectedDeck = _selectedDeck;

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	return self;
}

- (void)awakeFromNib
{
	self.fleetInfo = [HMFleetInformation new];
	self.selectedDeck = 1;
	
	[self.supplies1 bind:@"shipStatus"
				toObject:self.fleetInfo
			 withKeyPath:@"flagShip"
				 options:nil];
	[self.supplies2 bind:@"shipStatus"
				toObject:self.fleetInfo
			 withKeyPath:@"secondShip"
				 options:nil];
	[self.supplies3 bind:@"shipStatus"
				toObject:self.fleetInfo
			 withKeyPath:@"thirdShip"
				 options:nil];
	[self.supplies4 bind:@"shipStatus"
				toObject:self.fleetInfo
			 withKeyPath:@"fourthShip"
				 options:nil];
	[self.supplies5 bind:@"shipStatus"
				toObject:self.fleetInfo
			 withKeyPath:@"fifthShip"
				 options:nil];
	[self.supplies6 bind:@"shipStatus"
				toObject:self.fleetInfo
			 withKeyPath:@"sixthShip"
				 options:nil];

}

+ (NSSet *)keyPathsForValuesAffectingTotalSakuteki
{
	return [NSSet setWithObject:@"fleetInfo.totalSakuteki"];
}

- (NSNumber *)totalSakuteki
{
	return self.fleetInfo.totalSakuteki;
}
- (void)setSelectedDeck:(NSInteger)selectedDeck
{
	if(selectedDeck == _selectedDeck) return;
	_selectedDeck = selectedDeck;
	
	self.fleetInfo.selectedFleetNumber = @(selectedDeck);
}
- (NSInteger)selectedDeck
{
	return _selectedDeck;
}

@end
