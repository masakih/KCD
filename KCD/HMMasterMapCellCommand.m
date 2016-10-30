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
	return @"api_data.api_mst_mapcell";
}
- (NSArray *)ignoreKeys
{
	return @[@"api_req_shiptype", @"api_link_no"];
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"MasterMapCell"];
}
@end
