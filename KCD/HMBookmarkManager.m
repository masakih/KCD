//
//  HMBookmarkManager.m
//  KCD
//
//  Created by Hori,Masaki on 2015/05/27.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMBookmarkManager.h"


const NSUInteger kBookmarkMenuItemTag = 5000;


static HMBookmarkManager *sharedInstance = nil;
static NSMenu *bookmarkMenu = nil;


@interface HMBookmarkManager () <NSMenuDelegate>
@property (strong, nonatomic) NSMutableArray *realBookmarks;
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
		_realBookmarks = [NSMutableArray new];
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
	for(NSInteger i = itemNum - 1; i > 3; i--) {
		[bookmarkMenu removeItemAtIndex:i];
	}
	
	NSInteger bookmarkNum = self.count;
	for(NSInteger i = 0; i < bookmarkNum; i++) {
		HMBookmarkItem *item = self.bookmarks[i];
		NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:item.name
														 action:@selector(selectBookmark:)
												  keyEquivalent:@""];
		newItem.representedObject = item;
		[bookmarkMenu addItem:newItem];
	}
}

- (NSArray *)bookmarks
{
	return [self.realBookmarks copy];
}

- (NSUInteger)count
{
	return self.realBookmarks.count;
}
- (HMBookmarkItem *)bookmarkAtIndex:(NSUInteger)index
{
	return [self.realBookmarks objectAtIndex:index];
}

- (void)addBookmark:(HMBookmarkItem *)item
{
	[self.realBookmarks addObject:item];
	
	if(!item.identifier) {
		item.identifier = [NSString stringWithFormat:@"hogehogheo%@", [NSDate date]];
	}
}
- (void)insertBookmark:(HMBookmarkItem *)item atIndex:(NSUInteger)index
{
	[self.realBookmarks insertObject:item atIndex:index];
}
- (void)removeBookmark:(HMBookmarkItem *)item
{
	[self.realBookmarks removeObject:item];
}
- (void)removeBookmarkAtIndex:(NSUInteger)index
{
	[self.realBookmarks removeObjectAtIndex:index];
}
- (void)replaceBookmarkAtIndex:(NSUInteger)index withBookmark:(HMBookmarkItem *)item
{
	[self.realBookmarks replaceObjectAtIndex:index withObject:item];
}

@end
