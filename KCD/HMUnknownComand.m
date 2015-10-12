//
//  HMUnknownComand.m
//  KCD
//
//  Created by Hori,Masaki on 2015/10/09.
//  Copyright © 2015年 Hori,Masaki. All rights reserved.
//

#import "HMUnknownComand.h"

@implementation HMUnknownComand

- (void)execute
{
	NSLog(@"Unknown API command -> %@\nparameter -> %@\njson-> %@",
		  self.api, self.arguments, self.json);
}

@end
