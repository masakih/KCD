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

@interface HMStrengthenListViewController () <NSTableViewDataSource, NSURLSessionDelegate>

@property (strong) NSArray *equipmentStrengthenList;
@property (weak, nonatomic) IBOutlet NSTableView *tableView;
@property (strong) NSArray *itemList;

@property (nonatomic) NSInteger offsetDay;

@property (strong) HMPeriodicNotifier *notifier;


@property (strong) NSURLSession *plistDownloadSession;
@property (strong) NSOperationQueue *plistDownloadQueue;
@property (strong) NSURLSessionDownloadTask *plistDownloadTask;
@property (strong) HMPeriodicNotifier *plistDownloadNotifier;
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
		
		_plistDownloadNotifier = [HMPeriodicNotifier periodicNotifierWithHour:23 minutes:55];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(downloadPlist:)
													 name:HMPeriodicNotification
												   object:_plistDownloadNotifier];
		[self downloadPlist:nil];
	}
	return self;
}

- (void)setOffsetDay:(NSInteger)offsetDay
{
	_offsetDay = offsetDay;
	[self buildList:nil];
}

- (void)downloadPlist:(id)dummy
{
	NSURL *plistURL = [NSURL URLWithString:@"http://osdn.jp/users/masakih/pf/KCD/scm/blobs/master/KCD/EquipmentStrengthen.plist?export=raw"];
	
	if(!self.plistDownloadSession) {
		self.plistDownloadQueue = [NSOperationQueue new];
		self.plistDownloadQueue.name = @"HMStrengthenListViewControllerPlistDownloadQueue";
		self.plistDownloadQueue.maxConcurrentOperationCount = 1;
		if(floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
			self.plistDownloadQueue.qualityOfService = NSQualityOfServiceBackground;
		}
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
		self.plistDownloadSession = [NSURLSession sessionWithConfiguration:configuration
																  delegate:self
															 delegateQueue:self.plistDownloadQueue];
	}
	
	if(self.plistDownloadTask) return;
	
	self.plistDownloadTask = [self.plistDownloadSession downloadTaskWithURL:plistURL];
	
	[self.plistDownloadTask resume];
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
	NSError *error = nil;
	NSString *plistString = [NSString stringWithContentsOfURL:location
													 encoding:NSUTF8StringEncoding
														error:&error];
	if(!error && plistString) {
		NSArray *plist = [plistString propertyList];
		
		if([self.equipmentStrengthenList isEqual:plist]) return;
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
		NSURL *ownAppSuportURL = [appSupportURL URLByAppendingPathComponent:@"com.masakih.KCD"];
		NSURL *plistURL = [ownAppSuportURL URLByAppendingPathComponent:@"EquipmentStrengthen.plist"];
		
		NSArray *oldSavedPlist = [NSArray arrayWithContentsOfURL:plistURL];
		if(![oldSavedPlist isEqual:plist]) {
			[plist writeToURL:plistURL atomically:YES];
		}
		
		self.equipmentStrengthenList = plist;
		[self buildList:nil];
	}
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
	self.plistDownloadTask = nil;
}

- (void)buildList:(id)dummy
{
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSCalendarUnit unit = NSCalendarUnitWeekday;
	NSDateComponents *currentDay = [[NSCalendar currentCalendar] components:unit fromDate:now];
	
	NSInteger targetWeekday = currentDay.weekday + self.offsetDay;
	if(targetWeekday > 7) targetWeekday = 1;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"weekday = %ld", targetWeekday];
	
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
