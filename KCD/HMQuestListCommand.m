//
//  HMQuestListCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2015/04/15.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMQuestListCommand.h"

#import "HMServerDataStore.h"

#import "HMKCQuest.h"


@implementation HMQuestListCommand
+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[HMJSONCommand registerClass:self];
	});
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	if([api isEqualToString:@"/kcsapi/api_get_member/questlist"]) return YES;
	return NO;
}
//- (NSString *)dataKey
//{
//	return @"api_data.api_list";
//}
- (void)execute
{
	NSDictionary *data = [self.json valueForKeyPath:self.dataKey];
	NSArray *questList = data[@"api_list"];
	if([questList isKindOfClass:[NSNumber class]] || [questList isKindOfClass:[NSNull class]]) {
		return;
	}
	if(![questList isKindOfClass:[NSArray class]]) {
		[self log:@"api_data.api_list is NOT NSArray."];
		return;
	}
	
	NSString *entityName = @"Quest";
	
	HMServerDataStore *serverDataStore = [HMServerDataStore oneTimeEditor];
	NSManagedObjectContext *managedObjectContext = [serverDataStore managedObjectContext];
	NSError *error = nil;
	
	// 範囲内の任務をいったん遂行中からはずす
	if(questList.count == 0) return;
	NSNumber *min = @(0);
	NSNumber *max = @(9999);
	
	NSNumber *pageCount = data[@"api_page_count"];
	NSNumber *page = data[@"api_disp_page"];
	if(![page isEqual:pageCount]) {
		max = [questList.lastObject valueForKey:@"api_no"];
	}
	if(![page isEqual:@(1)]) {
		min = [questList[0] valueForKey:@"api_no"];
	}
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K >= %@) && (%K <= %@)", @"no", min, @"no", max];
	NSArray *objects = [serverDataStore objectsWithEntityName:entityName
											  sortDescriptors:nil
													predicate:predicate
														error:&error];
	for(HMKCQuest *quest in objects) {
		quest.state = @1;
	}
	
	// 新しいデータ投入
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"no" ascending:YES];
	objects = [serverDataStore objectsWithEntityName:entityName
									 sortDescriptors:@[sortDescriptor]
										   predicate:nil
											   error:&error];
	if(error) {
		[self log:@"Fetch error: %@", error];
		return;
	}
	
	NSRange range = NSMakeRange(0, objects.count);
	for(NSDictionary *type in questList) {
		id object = nil;
		if([type isKindOfClass:[NSNumber class]]) {
			continue;
		}
		NSUInteger index = [objects indexOfObject:type[@"api_no"]
									inSortedRange:range
										  options:NSBinarySearchingFirstEqual
								  usingComparator:^(id obj1, id obj2) {
									  id value1, value2;
									  if([obj1 isKindOfClass:[NSNumber class]]) {
										  value1 = obj1;
									  } else {
										  value1 = [obj1 valueForKey:@"no"];
									  }
									  if([obj2 isKindOfClass:[NSNumber class]]) {
										  value2 = obj2;
									  } else {
										  value2 = [obj2 valueForKey:@"no"];
									  }
									  return [value1 compare:value2];
								  }];
		if(index == NSNotFound) {
			object = [NSEntityDescription insertNewObjectForEntityForName:entityName
												   inManagedObjectContext:managedObjectContext];
		} else {
			object = objects[index];
		}
		
		for(NSString *key in type) {
			if([self.ignoreKeys containsObject:key]) continue;
			
			id value = type[key];
			if([value isKindOfClass:[NSArray class]]) {
				NSUInteger i = 0;
				for(id element in value) {
					id hoge = element;
					NSString *newKey = [NSString stringWithFormat:@"%@_%ld", key, i];
					if([object validateValue:&hoge forKey:newKey error:NULL]) {
						[self setValueIfNeeded:hoge toObject:object forKey:newKey];
					}
					i++;
				}
			} else if([value isKindOfClass:[NSDictionary class]]) {
				for(id subKey in value) {
					id subValue = value[subKey];
					NSString *newKey = [NSString stringWithFormat:@"%@_D_%@", key, keyByDeletingPrefix(subKey)];
					if([object validateValue:&subValue forKey:newKey error:NULL]) {
						[self setValueIfNeeded:subValue toObject:object forKey:newKey];
					}
				}
			} else {
				if([object validateValue:&value forKey:key error:NULL]) {
					[self setValueIfNeeded:value toObject:object forKey:key];
				}
			}
		}
	}

}
@end
