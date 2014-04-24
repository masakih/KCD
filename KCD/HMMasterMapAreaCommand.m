//
//  HMMasterMapAreaCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/16.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMasterMapAreaCommand.h"

@implementation HMMasterMapAreaCommand
- (NSString *)dataKey
{
	return @"api_data.api_mst_maparea";
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"MasterMapArea"];
}
@end
