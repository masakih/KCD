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


#define PATH_KEY2(key1, key2) [NSString stringWithFormat:@"%@.%@", (key1), (key2)]
#define PATH_KEY3(key1, key2, key3) [NSString stringWithFormat:@"%@.%@.%@", (key1), (key2), (key3)]

@implementation HMTSVSupport

#pragma mark## Save to Text file ##
static inline NSString *emptyStringIsNill(NSString *inString)
{
	return (inString) ? inString : @"";
}
- (NSArray *)allObjectOfEntityName:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors
{
	NSManagedObjectContext *moc = [[HMLocalDataStore defaultManager] managedObjectContext];
	NSError *error = nil;
	
	NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:entityName];
	[fetch setSortDescriptors:sortDescriptors];
	NSArray *fetchedArray = [moc executeFetchRequest:fetch
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
	
	return [self allObjectOfEntityName:entityName sortDescriptors:@[sort]];
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
	for(id obj in allObject) {
		NSString *element = [[NSString alloc] initWithFormat:@"%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@",
							 [obj valueForKey:@"date"],
							 [obj valueForKey:@"fuel"],
							 [obj valueForKey:@"bull"],
							 [obj valueForKey:@"steel"],
							 [obj valueForKey:@"bauxite"],
							 [obj valueForKey:@"kaihatusizai"],
							 [obj valueForKey:@"name"],
							 [obj valueForKey:@"flagShipName"],
							 [obj valueForKey:@"flagShipLv"],
							 [obj valueForKey:@"commanderLv"]
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
	for(id obj in allObject) {
		NSString *element = [[NSString alloc] initWithFormat:@"%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@",
							 [obj valueForKey:@"date"],
							 [obj valueForKey:@"fuel"],
							 [obj valueForKey:@"bull"],
							 [obj valueForKey:@"steel"],
							 [obj valueForKey:@"bauxite"],
							 [obj valueForKey:@"kaihatusizai"],
							 [obj valueForKey:@"name"],
							 [obj valueForKey:@"sTypeId"],
							 @"", //[obj valueForKey:@"flagShipName"],
							 [obj valueForKey:@"flagShipLv"],
							 [obj valueForKey:@"commanderLv"]
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
	NSManagedObjectContext *moc = [[HMLocalDataStore defaultManager] managedObjectContext];
	NSError *error = nil;
	NSFetchRequest *fetch;
	NSInteger num;
	
	fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:name
								 inManagedObjectContext:moc]];
	num = [moc countForFetchRequest:fetch
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
	if([self isEmptyEntityName:entityName]) {
		HMLocalDataStore *lds = [HMLocalDataStore oneTimeEditor];
		NSManagedObjectContext *moc = [lds managedObjectContext];
		
		contents = [self arrayFromLFSeparatedStringData:data];
		id attribute;
		for(attribute in contents) {
			NSArray *attr = [self arrayFromTabSeparatedString:attribute];
			if([attr count] < 1) continue;
			
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
	
}
- (void)buildKenzoistoryFromData:(NSData *)data
{
	NSString *entityName = @"KenzoHistory";
	NSArray *contents;
	if([self isEmptyEntityName:entityName]) {
		HMLocalDataStore *lds = [HMLocalDataStore oneTimeEditor];
		NSManagedObjectContext *moc = [lds managedObjectContext];
		
		contents = [self arrayFromLFSeparatedStringData:data];
		id attribute;
		for(attribute in contents) {
			NSArray *attr = [self arrayFromTabSeparatedString:attribute];
			if([attr count] < 1) continue;
			
			HMKenzoHistory *obj = [NSEntityDescription insertNewObjectForEntityForName:entityName
																inManagedObjectContext:moc];
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
		[self buildKenzoistoryFromData:[kenzo regularFileContents]];
	}];
}
@end
