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
	
	
	NSString *entityName = @"Quest";
	
	HMServerDataStore *serverDataStore = [HMServerDataStore oneTimeEditor];	
	NSError *error = nil;
	NSArray *objects = [serverDataStore objectsWithEntityName:entityName
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
	
	HMKCQuest *quest = objects[0];
	quest.progress_flag = @NO;
	quest.state = @1;
}
@end
