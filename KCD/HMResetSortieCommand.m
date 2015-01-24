//
//  HMResetSortieCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/12/07.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMResetSortieCommand.h"

#import "HMTemporaryDataStore.h"


@implementation HMResetSortieCommand

- (void)execute
{
	HMTemporaryDataStore *store = [HMTemporaryDataStore oneTimeEditor];
	NSManagedObjectContext *moc = store.managedObjectContext;
	
	NSError *error = nil;
	NSArray *array = [store objectsWithEntityName:@"Battle"
										predicate:nil
											error:NULL];
	if(error) {
		[self log:@"%s error: %@", __PRETTY_FUNCTION__, error];
		return;
	}
	for(id object in array) {
		[moc deleteObject:object];
	}
}

@end
