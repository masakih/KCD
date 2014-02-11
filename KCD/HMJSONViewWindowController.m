//
//  HMJSONViewWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMJSONViewWindowController.h"

@interface HMJSONViewWindowController ()
@property (retain, readwrite) NSMutableArray *commands;

@property (assign, readwrite) id json;
@end

@implementation HMJSONViewWindowController

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	if(self) {
		_commands = [NSMutableArray new];
	}
	return self;
}

- (void)awakeFromNib
{
	[self.apis addObserver:self
				forKeyPath:@"selection"
				   options:NSKeyValueObservingOptionNew
				   context:NULL];
}

- (void)setCommand:(NSDictionary *)command
{
	[self willChangeValueForKey:@"commands"];
	[self.commands addObject:command];
	[self didChangeValueForKey:@"commands"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"selection"]) {
		[self willChangeValueForKey:@"arguments"];
		self.arguments = [self.apis valueForKeyPath:@"selection.argument"];
		[self didChangeValueForKey:@"arguments"];
		
		[self willChangeValueForKey:@"json"];
		self.json = [self.apis valueForKeyPath:@"selection.json"];
		[self didChangeValueForKey:@"json"];
		
//		[self.argumentsView reloadData];
		[self.jsonView reloadData];
		
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	return 0;
}
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	return nil;
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return NO;
}
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	return nil;
}

@end
