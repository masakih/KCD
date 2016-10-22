//
//  HMJSONViewWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#ifdef DEBUG

#import "HMJSONViewWindowController.h"

@interface HMJSONViewWindowController ()
@property (nonatomic, weak) IBOutlet NSTableView *argumentsView;
@property (nonatomic, weak) IBOutlet NSOutlineView *jsonView;

@property (nonatomic, strong) IBOutlet NSArrayController *apis;

@property (nonatomic, strong, readwrite) NSMutableArray *commands;

@property (weak) NSArray *arguments;
@property (weak, readwrite) id json;
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
- (void)setCommandArray:(NSArray *)commands
{
	[self willChangeValueForKey:@"commands"];
	[self.commands addObjectsFromArray:commands];
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
				
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (IBAction)clearLog:(id)sender
{
	[self willChangeValueForKey:@"commands"];
	[self.commands removeAllObjects];
	[self didChangeValueForKey:@"commands"];
}

@end

#endif
