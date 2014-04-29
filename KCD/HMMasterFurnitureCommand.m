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
- (void)execute
{
	[self commitJSONToEntityNamed:@"MasterFurniture"];
}
@end
