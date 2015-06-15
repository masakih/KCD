//
//  HMStrengthenListViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2015/06/12.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMStrengthenListViewController.h"
#import "HMStrengthenListItemCellView.h"

#import "HMPeriodicNotifier.h"


static NSString *groupNameKey = @"group";

@interface HMStrengthenListViewController () <NSTableViewDataSource>

@property (strong) NSArray *equipmentStrengthenList;
@property (weak, nonatomic) IBOutlet NSTableView *tableView;
@property (strong) NSArray *itemList;

@property (nonatomic) NSInteger offsetDay;

@property (strong) HMPeriodicNotifier *notifier;
@end

@implementation HMStrengthenListViewController

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if(self) {
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSString *path = [mainBundle pathForResource:@"EquipmentStrengthen"
											  ofType:@"plist"];
		_equipmentStrengthenList = [[NSArray alloc] initWithContentsOfFile:path];
		if(!_equipmentStrengthenList) {
			NSLog(@"EquipmentStrengthen.plist not found.");
			return nil;
		}
		
		[self buildList:nil];
		
		_notifier = [HMPeriodicNotifier periodicNotifierWithHour:0 minutes:0];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(buildList:)
													 name:HMPeriodicNotification
												   object:_notifier];
	}
	return self;
}

- (void)setOffsetDay:(NSInteger)offsetDay
{
	_offsetDay = offsetDay;
	[self buildList:nil];
}

- (void)buildList:(id)dummy
{
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSCalendarUnit unit = NSCalendarUnitWeekday;
	NSDateComponents *currentDay = [[NSCalendar currentCalendar] components:unit fromDate:now];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"weekday = %ld", currentDay.weekday + self.offsetDay];
	
	NSArray *filterdItemList = [self.equipmentStrengthenList filteredArrayUsingPredicate:predicate];
	
	NSMutableArray *list = [NSMutableArray new];
	NSString *groupName = @"";
	
	for(NSDictionary *item in filterdItemList) {
		NSString *equipmentName = item[@"equipment"];
		if(![groupName isEqualToString:equipmentName]) {
			groupName = equipmentName;
			NSDictionary *group = @{groupNameKey : groupName };
			[list addObject:group];
		}
		[list addObject:item];
	}
	
	self.itemList = list;
	[_tableView reloadData];
}

#pragma mark - NSTableViewDelegate & NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return self.itemList.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSDictionary *item = self.itemList[row];
	if(item[groupNameKey]) {
		NSTableCellView *groupLabel = [tableView makeViewWithIdentifier:@"LabelCell" owner:self];
		groupLabel.textField.stringValue = item[groupNameKey];
		return groupLabel;
	} else {
		HMStrengthenListItemCellView *itemView = [tableView makeViewWithIdentifier:@"ItemCell" owner:self];
		itemView.textField.stringValue = item[@"secondShip"];
		itemView.secondField.stringValue = item[@"remodelEquipment"] ?: @"";
		return itemView;
	}
	return nil;
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
	NSDictionary *item = self.itemList[row];
	return item[groupNameKey] != nil;
}
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	NSDictionary *item = self.itemList[row];
	return item[groupNameKey] ? 17 : [tableView rowHeight];
}
@end
