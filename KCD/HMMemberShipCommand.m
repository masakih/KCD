//
//  HMMemberShipCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/23.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMemberShipCommand.h"

@interface HMMemberShipCommand ()
@property (strong) NSMutableArray *ids;
@end

@implementation HMMemberShipCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return [api isEqualToString:@"/kcsapi/api_get_member/ship"];
}

- (id)init
{
	self = [super init];
	if(self) {
		_ids = [NSMutableArray new];
	}
	return self;
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"Ship"];
}

// 取得後破棄した艦娘のデータを削除する
- (BOOL)handleExtraValue:(id)value forKey:(NSString *)key toObject:(NSManagedObject *)object
{
	if([key isEqualToString:@"api_id"]) {
		[self.ids addObject:value];
	}
	return NO;
}

- (void)finishOperating:(NSManagedObjectContext *)moc
{
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Ship"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT id IN %@", self.ids];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	if(error) {
		NSLog(@"HOGEEEEE");
		return;
	}
	
	for(id obj in array) {
		[moc deleteObject:obj];
	}
}

@end
