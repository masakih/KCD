//
//  HMJSONTracker.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMJSONTracker.h"

#import "HMQueue.h"
#import "HMJSONCommand.h"

static HMJSONTracker *sTracker = nil;

@interface HMJSONTracker ()
@property (strong) HMQueue *queue;

@property (strong) HMJSONReciever *reciever;

@end

@implementation HMJSONTracker
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sTracker = [HMJSONTracker new];
	});
}
- (id)init
{
	self = [super init];
	if(self) {
		_queue = [HMQueue new];
		_reciever = [HMJSONReciever new];
		self.reciever.queueu = self.queue;
		[self start];
	}
	return self;
}

- (void)start
{
	dispatch_queue_t queue = dispatch_queue_create("HMJSONTracker", DISPATCH_QUEUE_SERIAL);
	dispatch_async(queue, ^{
		while(YES) {
			@autoreleasepool {
				@try {
					id item = [self.queue dequeue];
					HMJSONCommand *command = [HMJSONCommand commandForAPIResult:item];
					[command execute];
					[NSThread sleepForTimeInterval:0.1];
				}
				@catch (id e) {
					NSLog(@"HMJSONTracker Cought Exception -> %@", e);
				}
			}
		}
	});
}

@end
