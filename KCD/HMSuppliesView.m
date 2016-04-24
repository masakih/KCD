//
//  HMSuppliesView.m
//  UITest
//
//  Created by Hori,Masaki on 2014/08/10.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMSuppliesView.h"
#import "HMSuppliesCell.h"

#import "HMKCShipObject+Extensions.h"



static void *ShipStatusContext = &ShipStatusContext;


@interface HMSuppliesView ()
@property (nonatomic, strong) HMSuppliesCell *suppliesCell;
@end


@implementation HMSuppliesView


- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
    if (self) {
		_suppliesCell = [HMSuppliesCell new];
		[self setCell:self.suppliesCell];
    }
    return self;
}

- (void)dealloc
{
	[self.suppliesCell.shipStatus removeObserver:self forKeyPath:@"fuel"];
	[self.suppliesCell.shipStatus removeObserver:self forKeyPath:@"maxFuel"];
	[self.suppliesCell.shipStatus removeObserver:self forKeyPath:@"bull"];
	[self.suppliesCell.shipStatus removeObserver:self forKeyPath:@"maxBull"];
}

- (void)setShipStatus:(HMKCShipObject *)shipStatus
{
	[self.suppliesCell.shipStatus removeObserver:self forKeyPath:@"fuel"];
	[self.suppliesCell.shipStatus removeObserver:self forKeyPath:@"maxFuel"];
	[self.suppliesCell.shipStatus removeObserver:self forKeyPath:@"bull"];
	[self.suppliesCell.shipStatus removeObserver:self forKeyPath:@"maxBull"];
	
	self.suppliesCell.shipStatus = shipStatus;
	
	[self.suppliesCell.shipStatus addObserver:self
								   forKeyPath:@"fuel"
									  options:NSKeyValueObservingOptionNew
									  context:ShipStatusContext];
	[self.suppliesCell.shipStatus addObserver:self
								   forKeyPath:@"maxFuel"
									  options:NSKeyValueObservingOptionNew
									  context:ShipStatusContext];
	[self.suppliesCell.shipStatus addObserver:self
								   forKeyPath:@"bull"
									  options:NSKeyValueObservingOptionNew
									  context:ShipStatusContext];
	[self.suppliesCell.shipStatus addObserver:self
								   forKeyPath:@"maxBull"
									  options:NSKeyValueObservingOptionNew
									  context:ShipStatusContext];
	
	[self setNeedsDisplay];
}
- (HMKCShipObject *)shipStatus
{
	return self.suppliesCell.shipStatus;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if(context ==ShipStatusContext) {
		[self setNeedsDisplay];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
