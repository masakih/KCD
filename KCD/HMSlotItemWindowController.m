//
//  HMSlotItemWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/04/29.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMSlotItemWindowController.h"

#import "HMServerDataStore.h"

@interface HMSlotItemWindowController ()

@end

@implementation HMSlotItemWindowController

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	return self;
}

- (void)awakeFromNib
{
	[self.slotItemController fetchWithRequest:nil merge:YES error:NULL];
	
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	id data = [ud objectForKey:@"slotItemSortKey"];
	id sortDescriptors = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	if(sortDescriptors) {
		[self.slotItemController setSortDescriptors:sortDescriptors];
	}
	
	[self.slotItemController addObserver:self
						  forKeyPath:NSSortDescriptorsBinding
							 options:0
							 context:NULL];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:NSSortDescriptorsBinding]) {
		NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
		id sortDescriptors = [self.slotItemController sortDescriptors];
		id data = [NSKeyedArchiver archivedDataWithRootObject:sortDescriptors];
		[ud setObject:data forKey:@"slotItemSortKey"];
		
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}

@end
