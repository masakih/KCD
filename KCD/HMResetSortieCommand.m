//
//  HMResetSortieCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/12/07.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMResetSortieCommand.h"

#import "HMTemporaryDataStore.h"
#import "HMKCBattle.h"


@implementation HMResetSortieCommand

- (void)execute
{
	HMTemporaryDataStore *store = [HMTemporaryDataStore oneTimeEditor];
	NSManagedObjectContext *moc = store.managedObjectContext;
	
	NSError *error = nil;
	NSArray<HMKCBattle *> *battles = [store objectsWithEntityName:@"Battle"
														predicate:nil
															error:NULL];
	if(error) {
		[self log:@"%s error: %@", __PRETTY_FUNCTION__, error];
		return;
	}
	for(HMKCBattle *object in battles) {
		[moc deleteObject:object];
	}
}

@end
