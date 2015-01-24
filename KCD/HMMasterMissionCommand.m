//
//  HMMasterMissionCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/17.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMasterMissionCommand.h"

@implementation HMMasterMissionCommand
- (NSString *)dataKey
{
	return @"api_data.api_mst_mission";
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"MasterMission"];
}
@end
