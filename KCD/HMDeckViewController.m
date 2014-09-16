//
//  HMDeckViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/04/12.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMDeckViewController.h"

#import "HMServerDataStore.h"

#import "HMSuppliesView.h"

@interface HMDeckViewController ()
@property (strong, nonatomic) NSNumber *sakuteki0;
@property (strong, nonatomic) NSNumber *sakuteki1;
@property (strong, nonatomic) NSNumber *sakuteki2;
@property (strong, nonatomic) NSNumber *sakuteki3;
@property (strong, nonatomic) NSNumber *sakuteki4;
@property (strong, nonatomic) NSNumber *sakuteki5;

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
	
	[self bind:@"sakuteki0" toObject:self.ship1Controller withKeyPath:@"selection.sakuteki_0" options:nil];
	[self bind:@"sakuteki1" toObject:self.ship2Controller withKeyPath:@"selection.sakuteki_0" options:nil];
	[self bind:@"sakuteki2" toObject:self.ship3Controller withKeyPath:@"selection.sakuteki_0" options:nil];
	[self bind:@"sakuteki3" toObject:self.ship4Controller withKeyPath:@"selection.sakuteki_0" options:nil];
	[self bind:@"sakuteki4" toObject:self.ship5Controller withKeyPath:@"selection.sakuteki_0" options:nil];
	[self bind:@"sakuteki5" toObject:self.ship6Controller withKeyPath:@"selection.sakuteki_0" options:nil];
	
	[self.supplies1 bind:@"shipStatus"
				toObject:self.ship1Controller
			 withKeyPath:@"selection.self"
				 options:nil];
	[self.supplies2 bind:@"shipStatus"
				toObject:self.ship2Controller
			 withKeyPath:@"selection.self"
				 options:nil];
	[self.supplies3 bind:@"shipStatus"
				toObject:self.ship3Controller
			 withKeyPath:@"selection.self"
				 options:nil];
	[self.supplies4 bind:@"shipStatus"
				toObject:self.ship4Controller
			 withKeyPath:@"selection.self"
				 options:nil];
	[self.supplies5 bind:@"shipStatus"
				toObject:self.ship5Controller
			 withKeyPath:@"selection.self"
				 options:nil];
	[self.supplies6 bind:@"shipStatus"
				toObject:self.ship6Controller
			 withKeyPath:@"selection.self"
				 options:nil];
}

+ (NSSet *)keyPathsForValuesAffectingTotalSakuteki
{
	return [NSSet setWithObjects:
			@"sakuteki0",
			@"sakuteki1",
			@"sakuteki2",
			@"sakuteki3",
			@"sakuteki4",
			@"sakuteki5",
			nil];
}

- (NSNumber *)totalSakuteki
{
	NSInteger total = 0;
	total += [self.sakuteki0 integerValue];
	total += [self.sakuteki1 integerValue];
	total += [self.sakuteki2 integerValue];
	total += [self.sakuteki3 integerValue];
	total += [self.sakuteki4 integerValue];
	total += [self.sakuteki5 integerValue];
	
	return @(total);
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
