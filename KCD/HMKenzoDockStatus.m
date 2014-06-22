//
//  HMKenzoDockStatus.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/10.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMKenzoDockStatus.h"

#import "HMServerDataStore.h"

enum {
	kNoShip = 0,
	
	kHasShip = 2,
	kComplete = 3,
	
	kNotOpen = -1,
};

@interface HMKenzoDockStatus ()
@property (strong) NSArrayController *controller;

@property (strong) NSNumber *number;
@property (strong, readwrite) NSNumber *time;
@property (readwrite) BOOL isTasking;
@property (readwrite) BOOL didNotify;

@end

@implementation HMKenzoDockStatus
- (id)initWithDockNumber:(NSInteger)dockNumber
{
	self = [super init];
	
	if(dockNumber < 1 || dockNumber > 4) {
		self = nil;
		return nil;
	}
	
	if(self) {
		_number = @(dockNumber);
		
		_controller = [NSArrayController new];
		[self.controller setManagedObjectContext:[HMServerDataStore defaultManager].managedObjectContext];
		[self.controller setEntityName:@"KenzoDock"];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %ld", dockNumber];
		[self.controller setFetchPredicate:predicate];
		[self.controller setAutomaticallyRearrangesObjects:YES];
		[self.controller fetch:nil];
		
		[self.controller addObserver:self
						  forKeyPath:@"selection.state"
							 options:0
							 context:NULL];
	}
	
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"selection.state"]) {
		NSInteger status = [[self.controller valueForKeyPath:@"selection.state"] integerValue];
		switch(status) {
			case kNoShip:
			case kNotOpen:
				if(self.isTasking) self.isTasking = NO;
				if(self.didNotify) self.didNotify = NO;
				break;
			case kHasShip:
			case kComplete:
				if(!self.isTasking) self.isTasking = YES;
				break;
			default:
				NSLog(@"Kenzo Dock status is %ld", status);
				break;
		}
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)update
{
	if(!self.isTasking) {
		self.time = nil;
		return;
	}
	
	NSNumber *compTimeValue = [self.controller valueForKeyPath:@"selection.complete_time"];
	if(![compTimeValue isKindOfClass:[NSNumber class]]) {
		self.time = nil;
		return;
	}
	
	NSTimeInterval compTime = (NSUInteger)([compTimeValue doubleValue] / 1000.0);
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
	NSTimeInterval diff = compTime - [now timeIntervalSince1970];
	
	if(diff < 0) {
		self.time = @(0);
	} else {
		self.time =  @(diff);
	}
	
	if(!self.didNotify) {
		if(diff <= 0) {
			NSUserNotification * notification = [NSUserNotification new];
			NSString *format = NSLocalizedString(@"It Will Finish Build at No.%@.", @"It Will Finish Build at No.%@.");
			notification.title = [NSString stringWithFormat:format, self.number];
			notification.informativeText = notification.title;
			[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
			
			self.didNotify = YES;
		}
	}
}

@end
