//
//  HMBookmarkManager.m
//  KCD
//
//  Created by Hori,Masaki on 2015/05/27.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMBookmarkManager.h"

const NSUInteger kBookmarkMenuItemTag = 5000;
const NSUInteger kSeparatorItemTag = 9999;


static HMBookmarkManager *sharedInstance = nil;
static NSMenu *bookmarkMenu = nil;


@interface HMBookmarkManager () <NSMenuDelegate>

@property (nonatomic, strong) NSArrayController *bookmarksController;

@property (readonly) HMBookmarkDataStore *editorStore;
@end

@implementation HMBookmarkManager

+ (void)load
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:[self sharedManager]
		   selector:@selector(applicationDidFinishLaunching:)
			   name:NSApplicationDidFinishLaunchingNotification
			 object:NSApp];
}

+ (instancetype)sharedManager
{
	if(sharedInstance) return sharedInstance;
	
	sharedInstance = [self new];
	return sharedInstance;
}

- (instancetype)init
{
	self = [super init];
	if(self) {
		_bookmarksController = [[NSArrayController alloc] initWithContent:nil];
		_bookmarksController.managedObjectContext = self.manageObjectContext;
		_bookmarksController.entityName = @"Bookmark";
		
		NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"order"
																   ascending:YES];
		_bookmarksController.sortDescriptors = @[sortDesc];
		
		
		[NSTimer scheduledTimerWithTimeInterval:0.1
										 target:self
									   selector:@selector(storeData:)
									   userInfo:nil
										repeats:YES];
	}
	return self;
}


- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
	NSMenuItem *bookmarkMenuItem = [mainMenu itemWithTag:kBookmarkMenuItemTag];
	bookmarkMenu = [bookmarkMenuItem submenu];
	
	[bookmarkMenu setDelegate:self];
	
	[self buildBookmarkMenu];
}
- (void)menuNeedsUpdate:(NSMenu*)menu
{
	[self buildBookmarkMenu];
}
- (void)buildBookmarkMenu
{
	NSInteger itemNum = bookmarkMenu.numberOfItems;
	for(NSInteger i = itemNum - 1; i > 0; i--) {
		NSMenuItem *item = [bookmarkMenu itemAtIndex:i];
		if([item tag] == kSeparatorItemTag) break;
		[bookmarkMenu removeItemAtIndex:i];
	}
	
	NSArray *bookmarksArray = self.bookmarks;
	NSInteger bookmarkNum = bookmarksArray.count;
	for(NSInteger i = 0; i < bookmarkNum; i++) {
		HMBookmarkItem *item = bookmarksArray[i];
		NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:item.name
														 action:@selector(selectBookmark:)
												  keyEquivalent:@""];
		newItem.representedObject = item;
		[bookmarkMenu addItem:newItem];
	}
}

- (NSManagedObjectContext *)manageObjectContext
{
	return [[HMBookmarkDataStore defaultManager] managedObjectContext];
}
- (HMBookmarkDataStore *)editorStore
{
	static HMBookmarkDataStore *_store = nil;
	if(_store) return _store;
	
	_store = [HMBookmarkDataStore oneTimeEditor];
	return _store;
}
- (void)storeData:(id)timer
{
	HMBookmarkDataStore *store = self.editorStore;
	NSManagedObjectContext *context = store.managedObjectContext;
	if(context.hasChanges) {
		[store saveAction:nil];
	}
}
- (HMBookmarkItem *)createNewBookmark
{
	NSNumber *maxOrder = [self.bookmarksController valueForKeyPath:@"arrangedObjects.@max.order"];
	
	HMBookmarkItem *object = [NSEntityDescription insertNewObjectForEntityForName:@"Bookmark"
														   inManagedObjectContext:self.editorStore.managedObjectContext];
	object.identifier = [NSString stringWithFormat:@"HMBM%@", [NSDate date]];
	object.order = @(maxOrder.integerValue + 100);

	return object;
}

- (NSArray *)bookmarks
{
	[self.bookmarksController fetch:nil];
	NSArray *array = self.bookmarksController.arrangedObjects;
	return array;
}


@end
