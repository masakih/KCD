//
//  HMDeckViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/04/12.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMDeckViewController.h"

#import "HMServerDataStore.h"


@interface HMDeckViewController ()

@end

@implementation HMDeckViewController
@synthesize selectedDeck = _selectedDeck;

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	return self;
}

- (NSManagedObjectContext *)manageObjectContext
{
	return [[HMServerDataStore defaultManager] managedObjectContext];
}


- (void)awakeFromNib
{
	self.selectedDeck = 1;
	
	[self.deckController addObserver:self
						  forKeyPath:@"selection.ship_0"
							 options:0
							 context:@"0"];
	[self.deckController addObserver:self
						  forKeyPath:@"selection.ship_1"
							 options:0
							 context:@"1"];
	[self.deckController addObserver:self
						  forKeyPath:@"selection.ship_2"
							 options:0
							 context:@"2"];
	[self.deckController addObserver:self
						  forKeyPath:@"selection.ship_3"
							 options:0
							 context:@"3"];
	[self.deckController addObserver:self
						  forKeyPath:@"selection.ship_4"
							 options:0
							 context:@"4"];
	[self.deckController addObserver:self
						  forKeyPath:@"selection.ship_5"
							 options:0
							 context:@"5"];
	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	id contextObject = (__bridge id)context;
	
	if([contextObject isKindOfClass:[NSString class]]) {
		NSInteger number = [contextObject integerValue];
		NSArray *controllers = @[self.ship1Controller, self.ship2Controller, self.ship3Controller, self.ship4Controller, self.ship5Controller, self.ship6Controller];
		NSArrayController *target = controllers[number];
		NSString *key = [NSString stringWithFormat:@"selection.ship_%ld", number];
		id shipID = [self.deckController valueForKeyPath:key];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", shipID];
		[target setFetchPredicate:predicate];
		
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)setSelectedDeck:(NSInteger)selectedDeck
{
	if(selectedDeck == _selectedDeck) return;
	_selectedDeck = selectedDeck;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %ld", selectedDeck];
	[self.deckController setFetchPredicate:predicate];
}
- (NSInteger)selectedDeck
{
	return _selectedDeck;
}

@end
