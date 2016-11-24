//
//  HMMapInfoCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2016/11/21.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMMapInfoCommand.h"

#import "HMAirBaseCommand.h"


@implementation HMMapInfoCommand
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [HMJSONCommand registerClass:self];
    });
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
    if([api isEqualToString:@"/kcsapi/api_get_member/mapinfo"]) return YES;
    
    return NO;
}

- (id)init
{
    self = [super initWithCommands:
            [HMAirBaseCommand new],
            nil];
    return self;
}

@end
