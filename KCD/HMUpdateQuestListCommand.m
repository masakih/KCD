//
//  HMUpdateQuestListCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2015/04/22.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMUpdateQuestListCommand.h"
#import "HMKCQuest.h"

#import "HMServerDataStore.h"

@implementation HMUpdateQuestListCommand
- (void)execute
{
	NSString *questNo = self.arguments[@"api_quest_id"];
	if(!questNo || [questNo isKindOfClass:[NSNull class]]) return;
	
	HMServerDataStore *serverDataStore = [HMServerDataStore oneTimeEditor];	
	NSError *error = nil;
	NSArray<HMKCQuest *> *objects = [serverDataStore objectsWithEntityName:@"Quest"
														error:&error
											  predicateFormat:@"%K = %@", @"no", @([questNo integerValue])];
	
	if(error) {
		[self log:@"Fetch error: %@", error];
		return;
	}
	if(objects.count == 0) {
		[self log:@"Could not find QuestList no %@", questNo];
		return;
	}
	
	objects[0].progress_flag = @NO;
	objects[0].state = @1;
}
@end
