//
//  HMBookmarkListViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2015/05/30.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMBookmarkListViewController.h"

#import "HMBookmarkManager.h"


const NSInteger kEditMenuItemTag = 1000;
const NSInteger kDeleteMenuItemTag = 5000;

@interface HMBookmarkListViewController ()

@property (readonly) NSManagedObjectContext *managedObjectContext;
@property (weak) IBOutlet NSArrayController *bookmarkController;
@property (weak) IBOutlet NSMenu *contextMenu;

- (IBAction)editBookmark:(id)sender;
- (IBAction)deleteBookmark:(id)sender;

@end

@implementation HMBookmarkListViewController

- (instancetype)init
{
	self = [super initWithNibName:NSStringFromClass([self class])
						   bundle:nil];
	return self;
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [HMBookmarkManager sharedManager].manageObjectContext;
}

- (IBAction)editBookmark:(id)sender
{
	
}
- (IBAction)deleteBookmark:(id)sender
{
	if(![sender respondsToSelector:@selector(representedObject)]) return;
	NSNumber *rowValue = [sender representedObject];
	NSInteger row = rowValue.integerValue;
	if(row == -1) return;
	if(row > [self.bookmarkController.arrangedObjects count]) return;
	
	[self.bookmarkController removeObjectAtArrangedObjectIndex:row];
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	NSTableView *tableView = [notification object];
	NSInteger selection = [tableView selectedRow];
	NSArray *array = self.bookmarkController.arrangedObjects;
	if(array.count > selection) {
		id obj = array[selection];
		HMBookmarkItem *item = [obj valueForKey:@"self"];
		[self.delegate didSelectBookmark:item];
	}
	
	[tableView deselectAll:nil];
}

- (NSMenu *)tableView:(NSTableView *)tableView menuForEvent:(NSEvent *)event
{
	NSPoint mouse = [tableView convertPoint:[event locationInWindow] fromView:nil];
	NSInteger row = [tableView rowAtPoint:mouse];
	
	NSMenuItem *editMenuItem = [self.contextMenu itemWithTag:kEditMenuItemTag];
	editMenuItem.representedObject = @(row);
	NSMenuItem *deleteMenuItem = [self.contextMenu itemWithTag:kDeleteMenuItemTag];
	deleteMenuItem.representedObject = @(row);
	
	return self.contextMenu;
}
@end
