//
//  HMTSVSupport.m
//  KCD
//
//  Created by Hori,Masaki on 2014/03/23.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMTSVSupport.h"

#import "HMLocalDataStore.h"
#import "HMKaihatuHistory.h"
#import "HMKenzoHistory.h"
#import "HMKenzoMark.h"

#define PATH_KEY2(key1, key2) [NSString stringWithFormat:@"%@.%@", (key1), (key2)]
#define PATH_KEY3(key1, key2, key3) [NSString stringWithFormat:@"%@.%@.%@", (key1), (key2), (key3)]

@interface HMTSVSupport ()
@property HMLocalDataStore *store;
@end
@implementation HMTSVSupport

- (NSManagedObjectContext *)managedObjectContext
{
	if(self.store) {
		return self.store.managedObjectContext;
	}
	
	self.store = [HMLocalDataStore oneTimeEditor];
	
	return self.store.managedObjectContext;
}

#pragma mark## Save to Text file ##
- (NSArray *)allObjectOfEntityName:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors
{
	NSError *error = nil;
	
	NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:entityName];
	[fetch setSortDescriptors:sortDescriptors];
	NSArray *fetchedArray = [self.managedObjectContext executeFetchRequest:fetch
																	 error:&error];
	if(error) {
		NSLog(@"%@", [error localizedDescription]);
		return nil;
	}
	
	return fetchedArray;
}
- (NSArray *)allObjectOfEntityName:(NSString *)entityName sortBy:(NSString *)propertyName ascending:(BOOL)ascending
{
	NSSortDescriptor *sort = nil;
	
	if(propertyName) {
		sort = [NSSortDescriptor sortDescriptorWithKey:propertyName ascending:ascending];
	}
	
	return [self allObjectOfEntityName:entityName sortDescriptors:sort ? @[sort] : nil];
}
- (NSArray *)allObjectOfEntityName:(NSString *)entityName
{
	return [self allObjectOfEntityName:entityName sortDescriptors:nil];
}
- (void)saveLFSeparetedArray:(NSArray *)array toFile:(NSString *)path
{
	NSError *error = nil;
	
	NSString *saveText = [array componentsJoinedByString:@"\n"];
	[saveText writeToFile:path
			   atomically:YES
				 encoding:NSUTF8StringEncoding
					error:&error];
	if(error) {
		NSLog(@"%@", [error localizedDescription]);
	}
}
- (NSData *)dataFromLFSeparatedArray:(NSArray *)array
{
	NSString *saveText = [array componentsJoinedByString:@"\n"];
	return [saveText dataUsingEncoding:NSUTF8StringEncoding];
}
- (NSData *)dataOfKaihatuHistory
{
	NSArray *allObject = [self allObjectOfEntityName:@"KaihatuHistory"
											  sortBy:@"date"
										   ascending:YES];
	if([allObject count] == 0) return nil;
	
	NSMutableArray *array = [NSMutableArray array];
	for(HMKaihatuHistory *obj in allObject) {
		NSString *element = [[NSString alloc] initWithFormat:@"%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@",
							 obj.date, obj.fuel, obj.bull,
							 obj.steel, obj.bauxite, obj.kaihatusizai,
							 obj.name, obj.flagShipName, obj.flagShipLv, obj.commanderLv
							 ];
		[array addObject:element];
	}
	
	return [self dataFromLFSeparatedArray:array];
}
- (NSData *)dataOfKenzoHistory
{
	NSArray *allObject = [self allObjectOfEntityName:@"KenzoHistory"
											  sortBy:@"date"
										   ascending:YES];
	if([allObject count] == 0) return nil;
	
	NSMutableArray *array = [NSMutableArray array];
	for(HMKenzoHistory *obj in allObject) {
		NSString *element = [[NSString alloc] initWithFormat:@"%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@",
							 obj.date, obj.fuel, obj.bull,
							 obj.steel, obj.bauxite, obj.kaihatusizai,
							 obj.name, obj.sTypeId, obj.flagShipName,
							 obj.flagShipLv, obj.commanderLv
							 ];
		[array addObject:element];
	}
	
	return [self dataFromLFSeparatedArray:array];
}
- (NSData *)dataOfKenzoMark
{
	NSArray *allObject = [self allObjectOfEntityName:@"KenzoMark"
											  sortBy:@"kDockId"
										   ascending:YES];
	if([allObject count] == 0) return nil;
	
	NSMutableArray *array = [NSMutableArray array];
	for(HMKenzoMark *obj in allObject) {
		NSString *element = [[NSString alloc] initWithFormat:@"%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@",
							 obj.created_ship_id, obj.fuel, obj.bull, obj.steel,
							 obj.bauxite, obj.kaihatusizai, obj.kDockId,
							 obj.flagShipName, obj.flagShipLv, obj.commanderLv
							 ];
		[array addObject:element];
	}
	
	return [self dataFromLFSeparatedArray:array];
}
- (IBAction)save:(id)sender
{
	NSSavePanel *panel = [NSSavePanel savePanel];
	[panel setAllowedFileTypes:@[@"kcdlocaldata"]];
	
	[panel beginWithCompletionHandler:^(NSInteger result) {
		if(result != NSOKButton) return;
		
		NSString *path = [panel.URL path];
		
		NSFileWrapper *fileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
		[fileWrapper setFilename:[path lastPathComponent]];
		[fileWrapper addRegularFileWithContents:[self dataOfKaihatuHistory]
							  preferredFilename:@"kaihatu.tsv"];
		[fileWrapper addRegularFileWithContents:[self dataOfKenzoHistory]
							  preferredFilename:@"kenzo.tsv"];
		[fileWrapper addRegularFileWithContents:[self dataOfKenzoMark]
							  preferredFilename:@"kenzoMark.tsv"];
		
		[fileWrapper writeToFile:path atomically:YES updateFilenames:NO];
	}];
}

#pragma mark## Initialize from Text ##
- (NSArray *)arrayFromLFSeparatedStringData:(NSData *)data
{
	NSString *content = [[NSString alloc] initWithData:data
											  encoding:NSUTF8StringEncoding];
	return [content componentsSeparatedByString:@"\x0a"];
}

- (NSArray *)arrayFromTabSeparatedString:(NSString *)string
{
	return [string componentsSeparatedByString:@"\t"];
}

- (BOOL)isEmptyEntityName:(NSString *)name
{
	NSError *error = nil;
	NSFetchRequest *fetch;
	NSInteger num;
	
	fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:name
								 inManagedObjectContext:self.managedObjectContext]];
	num = [self.managedObjectContext countForFetchRequest:fetch
													error:&error];
	fetch = nil;
	if(error) {
		NSLog(@"%@", [error localizedDescription]);
		return NO;
	}
	
	return num == 0;
}

- (void)buildKaihatuHistoryFromData:(NSData *)data
{
	NSString *entityName = @"KaihatuHistory";
	NSArray *contents;
	HMLocalDataStore *lds = [HMLocalDataStore oneTimeEditor];
	NSManagedObjectContext *moc = [lds managedObjectContext];
	
	contents = [self arrayFromLFSeparatedStringData:data];
	id attribute;
	for(attribute in contents) {
		NSArray *attr = [self arrayFromTabSeparatedString:attribute];
		if(attr.count == 0) continue;
		if([attr[6] isKindOfClass:[NSNull class]]) continue;
		if([attr[6] isEqual:@"(null)"]) continue;
		
		NSArray *array = [lds objectsWithEntityName:entityName
											  error:NULL
									predicateFormat:@"date = %@", [NSDate dateWithString:attr[0]]];
		if(array.count != 0) continue;
		
		HMKaihatuHistory *obj = [NSEntityDescription insertNewObjectForEntityForName:entityName
															  inManagedObjectContext:moc];
		obj.date = [NSDate dateWithString:attr[0]];
		obj.fuel = @([attr[1] integerValue]);
		obj.bull = @([attr[2] integerValue]);
		obj.steel = @([attr[3] integerValue]);
		obj.bauxite = @([attr[4] integerValue]);
		obj.kaihatusizai = @([attr[5] integerValue]);
		obj.name = attr[6];
		obj.flagShipName = attr[7];
		obj.flagShipLv = @([attr[8] integerValue]);
		obj.commanderLv = @([attr[9] integerValue]);
	}
}
- (void)buildKenzoHistoryFromData:(NSData *)data
{
	NSString *entityName = @"KenzoHistory";
	NSArray *contents;
	HMLocalDataStore *lds = [HMLocalDataStore oneTimeEditor];
	
	contents = [self arrayFromLFSeparatedStringData:data];
	id attribute;
	for(attribute in contents) {
		NSArray *attr = [self arrayFromTabSeparatedString:attribute];
		if(attr.count == 0) continue;
		if([attr[6] isKindOfClass:[NSNull class]]) continue;
		if([attr[6] isEqual:@"(null)"]) continue;
				
		NSArray *array = [lds objectsWithEntityName:entityName
											  error:NULL
									predicateFormat:@"date = %@", [NSDate dateWithString:attr[0]]];
		if(array.count != 0) continue;
		
		HMKenzoHistory *obj = [NSEntityDescription insertNewObjectForEntityForName:entityName
															inManagedObjectContext:lds.managedObjectContext];
		
		obj.date = [NSDate dateWithString:attr[0]];
		obj.fuel = @([attr[1] integerValue]);
		obj.bull = @([attr[2] integerValue]);
		obj.steel = @([attr[3] integerValue]);
		obj.bauxite = @([attr[4] integerValue]);
		obj.kaihatusizai = @([attr[5] integerValue]);
		obj.name = attr[6];
		obj.sTypeId = @([attr[7] integerValue]);
		obj.flagShipName = attr[8];
		obj.flagShipLv = @([attr[9] integerValue]);
		obj.commanderLv = @([attr[10] integerValue]);
	}
}
- (void)buildKenzoMarkFromData:(NSData *)data
{
	NSString *entityName = @"KenzoMark";
	NSArray *contents;
	if([self isEmptyEntityName:entityName]) {
		HMLocalDataStore *lds = [HMLocalDataStore oneTimeEditor];
		NSManagedObjectContext *moc = [lds managedObjectContext];
		
		contents = [self arrayFromLFSeparatedStringData:data];
		id attribute;
		for(attribute in contents) {
			NSArray *attr = [self arrayFromTabSeparatedString:attribute];
			if([attr count] < 1) continue;
			
			HMKenzoMark *obj = [NSEntityDescription insertNewObjectForEntityForName:entityName
																inManagedObjectContext:moc];
			obj.created_ship_id = @([attr[0] integerValue]);
			obj.fuel = @([attr[1] integerValue]);
			obj.bull = @([attr[2] integerValue]);
			obj.steel = @([attr[3] integerValue]);
			obj.bauxite = @([attr[4] integerValue]);
			obj.kaihatusizai = @([attr[5] integerValue]);
			obj.kDockId = @([attr[6] integerValue]);
			obj.flagShipName = attr[7];
			obj.flagShipLv = @([attr[8] integerValue]);
			obj.commanderLv = @([attr[9] integerValue]);
		}
	}
	
}
- (IBAction)load:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setAllowedFileTypes:@[@"kcdlocaldata"]];
	
	[panel beginWithCompletionHandler:^(NSInteger result) {
		if(result != NSOKButton) return;
		
		NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithURL:panel.URL
															options:0
															  error:NULL];
		NSDictionary *children = [wrapper fileWrappers];
		NSFileWrapper *kaihatu = [children objectForKey:@"kaihatu.tsv"];
		[self buildKaihatuHistoryFromData:[kaihatu regularFileContents]];
		
		NSFileWrapper *kenzo = [children objectForKey:@"kenzo.tsv"];
		[self buildKenzoHistoryFromData:[kenzo regularFileContents]];
		
		NSFileWrapper *kenzoMark = [children objectForKey:@"kenzoMark.tsv"];
		[self buildKenzoMarkFromData:[kenzoMark regularFileContents]];
	}];
}
@end
