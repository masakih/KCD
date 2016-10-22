//
//  HMQueue.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMQueue.h"

@interface HMQueue ()
@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) NSCondition *lock;
@end

@implementation HMQueue

- (id)init
{
	self = [super init];
	if(self) {
		_contents = [NSMutableArray array];
		_lock = [NSCondition new];
	}
	return self;
}

- (id)dequeue
{
	id object = nil;
	
	[self.lock lock];
	@try {
		while([self.contents count] == 0) {
			[self.lock wait];
		}
		object = [self.contents lastObject];
		[self.contents removeLastObject];
	}
	@finally {
		[self.lock unlock];
	}
	
	return object;
}

- (void)enqueue:(id)object
{
	[self.lock lock];
	@try {
		[self.contents addObject:object];
		[self.lock broadcast];
	}
	@finally {
		[self.lock unlock];
	}
}

@end
