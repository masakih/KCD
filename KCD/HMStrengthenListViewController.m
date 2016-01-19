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

- (void)buildList:(id)dummy
{
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0.0];
	NSCalendarUnit unit = NSCalendarUnitWeekday;
	NSDateComponents *currentDay = [[NSCalendar currentCalendar] components:unit fromDate:now];
	
	NSPredicate *predicate = nil;
	if(self.offsetDay != -1) {
		NSInteger targetWeekday = currentDay.weekday + self.offsetDay;
		if(targetWeekday > 7) targetWeekday = 1;
		predicate = [NSPredicate predicateWithFormat:@"weekday = %ld", targetWeekday];
	}
	self.itemList = [self.equipmentStrengthenList filteredArrayUsingPredicate:predicate];
	
	[_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark - NSTableViewDelegate & NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return self.itemList.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	HMEnhancementListItem *item = self.itemList[row];
	HMStrengthenListItemCellView *itemView = [tableView makeViewWithIdentifier:@"ItemCell" owner:self];
	itemView.item = item;
	return itemView;
}

@end
