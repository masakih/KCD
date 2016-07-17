//
//  HMStrengthenListViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2015/06/12.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMStrengthenListViewController.h"
#import "HMStrengthenListItemCellView.h"

#import "HMEnhancementListItem.h"

#import "HMPeriodicNotifier.h"


static NSString *groupNameKey = @"group";

@interface HMStrengthenListViewController () <NSTableViewDataSource, NSURLSessionDelegate>

@property (strong) NSArray<HMEnhancementListItem *> *equipmentStrengthenList;
@property (weak, nonatomic) IBOutlet NSTableView *tableView;
@property (strong) NSArray<HMEnhancementListItem *> *itemList;

@property (nonatomic) NSInteger offsetDay;

@property (strong) HMPeriodicNotifier *notifier;


@property (strong) NSURLSession *plistDownloadSession;
@property (strong) NSOperationQueue *plistDownloadQueue;
@property (strong) NSURLSessionDownloadTask *plistDownloadTask;
@property (strong) HMPeriodicNotifier *plistDownloadNotifier;
@end

@implementation HMStrengthenListViewController
@synthesize itemList = _itemList;

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if(self) {
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSString *path = [mainBundle pathForResource:@"HMEnhancementListItem"
											  ofType:@"plist"];
		NSData *data = [NSData dataWithContentsOfFile:path];
		_equipmentStrengthenList = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		if(!_equipmentStrengthenList) {
			NSLog(@"HMEnhancementListItem.plist not found.");
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
#ifndef DEBUG
		[self downloadPlist:nil];
#endif
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
	NSURL *plistURL = [NSURL URLWithString:@"http://git.osdn.jp/view?p=kcd/KCD.git;a=blob;f=KCD/HMEnhancementListItem.plist;hb=HEAD"];
	
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
	NSData *data = [NSData dataWithContentsOfURL:location
												options:0
												  error:&error];
	if(!error && data) {
		NSArray *dataArray = nil;
		@try {
			dataArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		}
		@catch (id e) {
			NSLog(@"can not unarchive HMEnhancementListItem.plist. Reason: %@", e);
			return;
		}
		if(!dataArray) return;
		
		if([self.equipmentStrengthenList isEqual:dataArray]) return;
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
		NSURL *ownAppSuportURL = [appSupportURL URLByAppendingPathComponent:@"com.masakih.KCD"];
		NSURL *dataURL = [ownAppSuportURL URLByAppendingPathComponent:@"HMEnhancementListItem.plist"];
		
		NSData *oldSavedData = [NSData dataWithContentsOfURL:dataURL];
		if(![oldSavedData isEqual:data]) {
			[data writeToURL:dataURL atomically:YES];
		}
		
		self.equipmentStrengthenList = dataArray;
		[self buildList:nil];
	}
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
	self.plistDownloadTask = nil;
}

- (void)setItemList:(NSArray<HMEnhancementListItem *> *)itemList
{
	NSValueTransformer *tf = [NSValueTransformer valueTransformerForName:@"HMSlotItemEquipTypeTransformer"];
	
	NSMutableArray<HMEnhancementListItem *> *mutableItemList = [itemList mutableCopy];
	
	__block NSNumber *type = nil;
	NSMutableArray *group = [NSMutableArray array];
	
	[itemList enumerateObjectsUsingBlock:^(HMEnhancementListItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if(![type isEqualToNumber:obj.equipmentType]) {
			type = obj.equipmentType;
			[group addObject:@{ @"type" : type, @"index" : @(idx)}];
		}
	}];
	
	for(NSDictionary *dict in group.reverseObjectEnumerator) {
		NSUInteger index = [dict[@"index"] integerValue];
		NSString *typeName = [tf transformedValue:dict[@"type"]];
		
		HMEnhancementListItem *item = [HMEnhancementListItem new];
		item.identifire = typeName;
		item.equipmentType = @(-1);
		
		[mutableItemList insertObject:item atIndex:index];
	}
	
	_itemList = [mutableItemList copy];
}
- (NSArray<HMEnhancementListItem *> *)itemList
{
	return _itemList;
}

- (NSArray<HMEnhancementListItem *> *)allItemList
{
	NSMutableDictionary<NSString *, HMEnhancementListItem *> *dict = [NSMutableDictionary dictionary];
	NSMutableArray<HMEnhancementListItem *> *array = [NSMutableArray array];
	
	for(HMEnhancementListItem *item in self.equipmentStrengthenList) {
		HMEnhancementListItem *obj = [dict objectForKey:item.identifire];
		if(!obj) {
			obj = [item copy];
			obj.weekday = @10;
			[dict setObject:obj forKey:item.identifire];
			[array addObject:obj];
		}
		
		NSMutableOrderedSet<NSString *> *set = [NSMutableOrderedSet orderedSetWithArray:obj.secondsShipNames];
		[set addObjectsFromArray:item.secondsShipNames];
		obj.secondsShipNames = set.array;
	}
	
	return array;
}

- (void)refreshTableView
{
	if(self.offsetDay == -1) {
		self.itemList = [self allItemList];
		return;
	}
	
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSCalendarUnit unit = NSCalendarUnitWeekday;
	NSDateComponents *currentDay = [[NSCalendar currentCalendar] components:unit fromDate:now];
	
	NSInteger targetWeekday = currentDay.weekday + self.offsetDay;
	if(targetWeekday > 7) targetWeekday = 1;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"weekday = %ld", targetWeekday];
	self.itemList = [self.equipmentStrengthenList filteredArrayUsingPredicate:predicate];
}

- (void)buildList:(id)dummy
{
	[self performSelectorOnMainThread:@selector(refreshTableView) withObject:nil waitUntilDone:NO];
}

#pragma mark - NSTableViewDelegate & NSTableViewDataSource

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	HMEnhancementListItem *item = self.itemList[row];
	if([item.equipmentType isEqualToNumber:@(-1)]) {
		HMStrengthenListItemCellView *itemView = [tableView makeViewWithIdentifier:@"GroupCell" owner:nil];
		return itemView;
	}
	HMStrengthenListItemCellView *itemView = [tableView makeViewWithIdentifier:@"ItemCell" owner:nil];
	return itemView;
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
	HMEnhancementListItem *item = self.itemList[row];
	if([item.equipmentType isEqualToNumber:@(-1)]) {
		return YES;
	}
	
	return NO;
}
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	HMEnhancementListItem *item = self.itemList[row];
	if([item.equipmentType isEqualToNumber:@(-1)]) {
		return 23;
	}
	
	return 103;
}

@end
