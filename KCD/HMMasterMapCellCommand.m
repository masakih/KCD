//
//  HMMasterMapCellCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/17.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMasterMapCellCommand.h"

@implementation HMMasterMapCellCommand
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
- (void)execute
{
	[self commitJSONToEntityNamed:@"MasterMapCell"];
}
@end
