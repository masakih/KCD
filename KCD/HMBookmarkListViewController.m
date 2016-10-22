//
//  HMBookmarkListViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2015/05/30.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMBookmarkListViewController.h"

#import "HMBookmarkManager.h"
#import "HMBookmarkEditorViewController.h"


const NSInteger kEditMenuItemTag = 1000;
const NSInteger kDeleteMenuItemTag = 5000;

@interface HMBookmarkListViewController () <NSTableViewDataSource>

@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) IBOutlet NSArrayController *bookmarkController;
@property (nonatomic, strong) IBOutlet NSMenu *contextMenu;

@property (nonatomic, weak) IBOutlet NSPopover *popover;
@property (nonatomic, strong) HMBookmarkEditorViewController *editorController;

@property NSRange objectRange;
@property (nonatomic, copy) NSArray *currentlyDraggedObjects;

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
- (void)awakeFromNib
{
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
	[self.bookmarkController setSortDescriptors:@[sortDescriptor]];
	
	self.editorController = [HMBookmarkEditorViewController new];
	self.popover.contentViewController = self.editorController;
	
	[self.tableView registerForDraggedTypes:@[@"com.masakih.KCD.HMBookmarkItem"]];
	[self.tableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [HMBookmarkManager sharedManager].manageObjectContext;
}

- (IBAction)editBookmark:(id)sender
{
	if(![sender respondsToSelector:@selector(representedObject)]) return;
	NSNumber *rowValue = [sender representedObject];
	NSInteger row = rowValue.integerValue;
	if(row == -1) return;
	if(row < [self.bookmarkController.arrangedObjects count]) {
		self.editorController.representedObject = [self.bookmarkController.arrangedObjects objectAtIndex:row];
	}
	
	NSRect itemRect = [self.tableView rectOfRow:row];
	
	[self.popover showRelativeToRect:itemRect
							  ofView:self.tableView
					   preferredEdge:NSMinYEdge];
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

- (void)reorderingBoolmarks
{
	NSInteger order = 100;
	for(HMBookmarkItem *item in self.bookmarkController.arrangedObjects) {
		item.order = @(order);
		order += 100;
	}
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
	
	if(row == -1) return nil;
	
	NSMenuItem *editMenuItem = [self.contextMenu itemWithTag:kEditMenuItemTag];
	editMenuItem.representedObject = @(row);
	NSMenuItem *deleteMenuItem = [self.contextMenu itemWithTag:kDeleteMenuItemTag];
	deleteMenuItem.representedObject = @(row);
	
	return self.contextMenu;
}

- (id<NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row
{
	return [self.bookmarkController.arrangedObjects objectAtIndex:row];
}

- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forRowIndexes:(NSIndexSet *)rowIndexes
{
	NSUInteger len = ([rowIndexes lastIndex]+1) - [rowIndexes firstIndex];
	self.objectRange = NSMakeRange([rowIndexes firstIndex], len);
	self.currentlyDraggedObjects = [self.bookmarkController.arrangedObjects objectsAtIndexes:rowIndexes];
}

- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
	self.objectRange = NSMakeRange(0, 0);
	self.currentlyDraggedObjects = nil;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
	if(dropOperation == NSTableViewDropAbove && (_objectRange.location > row || _objectRange.location + _objectRange.length < row)) {
		if([info draggingSource] == tableView) {
			return NSDragOperationMove;
		}
	}
	return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
	[self.tableView beginUpdates];
	
	HMBookmarkDataStore *store = [[HMBookmarkManager sharedManager] editorStore];
	HMBookmarkItem *target = nil;
	if(row != 0) {
		target = [self.bookmarkController.arrangedObjects objectAtIndex:row - 1];
	}
	NSInteger targetOrder = target.order.integerValue;
	NSArray *items = [info draggingPasteboard].pasteboardItems;
	NSInteger i = 1;
	for(NSPasteboardItem *item in items) {
		id p = [item dataForType:@"com.masakih.KCD.HMBookmarkItem"];
		NSURL *uri = [NSKeyedUnarchiver unarchiveObjectWithData:p];
		NSManagedObjectID *oID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
		HMBookmarkItem *bookmark = (HMBookmarkItem *)[store.managedObjectContext objectWithID:oID];
		bookmark.order = @(targetOrder + i);
		i++;
	}
	[self.bookmarkController rearrangeObjects];
	[self reorderingBoolmarks];
	[self.bookmarkController rearrangeObjects];
	
	[self.tableView endUpdates];
	return YES;
}

@end
