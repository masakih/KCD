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


@interface HMJSONTracker ()
@property (retain) HMQueue *queue;

@property (retain) HMJSONReciever *reciever;

@end

@implementation HMJSONTracker

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
	dispatch_queue_t queue = dispatch_queue_create("HMJSONTracker", 0);
	dispatch_async(queue, ^{
		while(YES) {
			NSDictionary *item = [self.queue dequeue];
			HMJSONCommand *command = [HMJSONCommand commandForAPI:[item objectForKey:@"api"]];
			command.argumentsString = [item objectForKey:@"arg"];
			[command doCommand:[item objectForKey:@"json"]];
			
		}
	});
}

@end
