//
//  HMMasterUseItemCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/16.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMMasterUseItemCommand.h"

@implementation HMMasterUseItemCommand
- (NSString *)dataKey
{
	return @"api_data.api_mst_useitem";
}
- (void)execute
{
	[self commitJSONToEntityNamed:@"MasterUseItem"];
}
@end
