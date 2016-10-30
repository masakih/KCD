//
//  HMMasterSTypeCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/13.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMasterSTypeCommand.h"

@implementation HMMasterSTypeCommand
- (NSArray *)ignoreKeys
{
	return @[@"api_equip_type"];
}
- (NSString *)dataKey
{
	return @"api_data.api_mst_stype";
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"MasterSType"];
}
@end
