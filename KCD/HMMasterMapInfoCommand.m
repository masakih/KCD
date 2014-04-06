//
//  HMMasterMapInfoCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/16.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMasterMapInfoCommand.h"

@implementation HMMasterMapInfoCommand
- (NSString *)dataKey
{
	return @"api_data_mst_mapinfo";
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"MasterMapInfo"];
}
@end
