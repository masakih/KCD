//
//  HMMasterMapCellCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/17.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMasterMapCellCommand.h"

@implementation HMMasterMapCellCommand
//+ (void)load
//{
//	static dispatch_once_t onceToken;
//	dispatch_once(&onceToken, ^{
//		[HMJSONCommand registerClass:self];
//	});
//}
//
//+ (BOOL)canExcuteAPI:(NSString *)api
//{
//	return [api isEqualToString:@"/kcsapi/api_get_master/mapcell"];
//}
- (NSString *)dataKey
{
	return @"api_data_mst_mapcell";
}
- (NSArray *)ignoreKeys
{
	static NSArray *ignoreKeys = nil;
	if(ignoreKeys) return ignoreKeys;
	
	ignoreKeys = @[@"api_req_shiptype", @"api_link_no"];
	
	return ignoreKeys;
}
//- (BOOL)handleExtraValue:(id)value forKey:(NSString *)key toObject:(NSManagedObject *)object
//{
//	NSArray *list = @[@"api_req_shiptype", @"api_link_no"];
//	if([list containsObject:key] && (!value || [value isKindOfClass:[NSNull class]])) return YES;
//	return NO;
//}
- (void)execute
{
	[self commitJSONToEntityNamed:@"MasterMapCell"];
}
@end
