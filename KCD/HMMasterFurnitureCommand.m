//
//  HMMasterFurnitureCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/17.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMasterFurnitureCommand.h"

@implementation HMMasterFurnitureCommand
- (NSString *)dataKey
{
	return @"api_data.api_mst_furniture";
}
- (NSArray *)ignoreKeys
{
	return @[@"api_season"];
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"MasterFurniture"];
}
@end
