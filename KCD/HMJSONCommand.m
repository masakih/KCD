//
//  HMJSONCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMJSONCommand.h"

#import "HMAppDelegate.h"
#import "HMServerDataStore.h"

#if ENABLE_JSON_LOG
#import "HMJSONNode.h"
#import "HMCompositCommand.h"
#import "HMJSONViewCommand.h"
#endif

static NSMutableArray *registeredCommands = nil;

@interface HMJSONCommand ()
@property (strong, readwrite) NSDictionary *arguments;
@property (copy, readwrite) NSString *api;
@property (strong, readwrite) id json;

#if ENABLE_JSON_LOG
@property (strong, readwrite) NSArray *jsonTree;
@property (strong, readwrite) NSArray *argumentArray;
#endif
@end

@implementation HMJSONCommand
@synthesize argumentsString = _argumentsString;
@synthesize jsonData = _jsonData;

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		registeredCommands = [NSMutableArray new];
	});
}

+ (HMJSONCommand *)commandForAPIResult:(HMAPIResult *)apiResult
{
	HMJSONCommand *command = nil;
	
#if ENABLE_JSON_LOG
	HMJSONViewCommand *viewCommand = [HMJSONViewCommand new];
	viewCommand.api = apiResult.api;
	viewCommand.arguments = apiResult.parameter;
	viewCommand.json = apiResult.json;
	viewCommand.argumentArray = apiResult.argumentArray;
	viewCommand.jsonTree = @[[HMJSONNode nodeWithJSON:apiResult.json]];
	viewCommand.recieveDate = apiResult.date;
	
	command = viewCommand;
#endif
	
	for(Class commandClass in registeredCommands) {
		if([commandClass canExcuteAPI:apiResult.api]) {
			command =  [commandClass new];
			command.api = apiResult.api;
			command.arguments = apiResult.parameter;
			command.json = apiResult.json;
			
#if ENABLE_JSON_LOG_HANDLED_API
			command = [HMCompositCommand compositCommandWithCommands:command, viewCommand, nil];
#endif
			return command;
		}
	}
	
	return command;
}

+ (void)registerClass:(Class)commandClass
{
	if(!commandClass) return;
	if([registeredCommands containsObject:commandClass]) return;
	[registeredCommands addObject:commandClass];
}

NSString *keyByDeletingPrefix(NSString *key)
{
	NSString *newKye = nil;
	@try {
		newKye = [key substringFromIndex:4];
	}
	@catch (NSException *exception) {
		NSLog(@"key is %@", key);
	}
	return newKye;
}
- (void)log:(NSString *)format, ...
{
	va_list ap;
	va_start(ap, format);
	NSString *str = [[NSString alloc] initWithFormat:format arguments:ap];
	NSLog(@"API: %@, Arguments: %@.\n%@", self.api, self.arguments, str);
	va_end(ap);
}

- (NSString *)dataKey
{
	return @"api_data";
}

- (void)setValueIfNeeded:(id)value toObject:(id)object forKey:(NSString *)key
{
	id oldValue = [object valueForKey:key];
	if(![oldValue isEqual:value]) {
		[object willChangeValueForKey:key];
		[object setValue:value forKey:key];
		[object didChangeValueForKey:key];
		
	}
}
- (void)registerElement:(NSDictionary *)element toObject:(NSManagedObject *)object
{
	if(!object) return;
	
	for(NSString *key in element) {
		if([self.ignoreKeys containsObject:key]) continue;
		
		id value = element[key];
		if([self handleExtraValue:value forKey:key toObject:object]) {
			continue;
		}
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
- (void)commitJSONToEntityNamed:(NSString *)entityName
{
	NSArray *api_data = [self.json valueForKeyPath:self.dataKey];
	if([api_data isKindOfClass:[NSDictionary class]]) {
		api_data = @[api_data];
	}
	if(![api_data isKindOfClass:[NSArray class]]) {
		[self log:@"api_data is NOT NSArray."];
		return;
	}
	
	HMServerDataStore *serverDataStore = [HMServerDataStore oneTimeEditor];
	NSManagedObjectContext *managedObjectContext = [serverDataStore managedObjectContext];
	
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
	NSError *error = nil;
	NSArray *objects = [serverDataStore objectsWithEntityName:entityName
											  sortDescriptors:@[sortDescriptor]
													predicate:nil
														error:&error];
	if(error) {
		[self log:@"Fetch error: %@", error];
		return;
	}
	
	NSRange range = NSMakeRange(0, objects.count);
	for(NSDictionary *element in api_data) {
		NSUInteger index = [objects indexOfObject:element[@"api_id"]
									inSortedRange:range
										  options:NSBinarySearchingFirstEqual
								  usingComparator:^(id obj1, id obj2) {
									  id value1, value2;
									  if([obj1 isKindOfClass:[NSNumber class]]) {
										  value1 = obj1;
									  } else {
										  value1 = [obj1 valueForKey:@"id"];
									  }
									  if([obj2 isKindOfClass:[NSNumber class]]) {
										  value2 = obj2;
									  } else {
										  value2 = [obj2 valueForKey:@"id"];
									  }
									  return [value1 compare:value2];
								  }];
		
		NSManagedObject *object = nil;
		if(index == NSNotFound) {
			object = [NSEntityDescription insertNewObjectForEntityForName:entityName
												   inManagedObjectContext:managedObjectContext];
		} else {
			object = objects[index];
		}
		
		[self registerElement:element
					 toObject:object];
	}
	[self finishOperating:managedObjectContext];
}

// abstruct
- (void)execute
{
	NSLog(@"Enter %s", __PRETTY_FUNCTION__);
	assert(NO);
}

+ (BOOL)canExcuteAPI:(NSString *)api
{
	return NO;
}

- (BOOL)handleExtraValue:(id)value forKey:(NSString *)key toObject:(NSManagedObject *)object
{
	return NO;
}
- (void)finishOperating:(NSManagedObjectContext *)moc
{
	
}

@end
