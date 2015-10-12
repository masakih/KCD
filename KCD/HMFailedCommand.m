//
//  HMFailedCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2015/10/10.
//  Copyright © 2015年 Hori,Masaki. All rights reserved.
//

#import "HMFailedCommand.h"

@implementation HMFailedCommand
- (void)execute
{
	NSLog(@"Fail API command -> %@\nparameter -> %@\njson-> %@",
		  self.api, self.arguments, self.json);
}
@end
