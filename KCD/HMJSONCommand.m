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

+ (HMJSONCommand *)commandForAPI:(NSString *)api
{
	for(Class commandClass in registeredCommands) {
		if([commandClass canExcuteAPI:api]) {
			HMJSONCommand *command =  [commandClass new];
			command.api = api;
#if ENABLE_JSON_LOG_HANDLED_API
			HMJSONViewCommand *viewCommand = [HMJSONViewCommand new];
			viewCommand.api = api;
			command = [HMCompositCommand compositCommandWithCommands:command, viewCommand, nil];
#endif
			return command;
		}
	}
#if ENABLE_JSON_LOG
	HMJSONViewCommand *viewCommand = [HMJSONViewCommand new];
	viewCommand.api = api;
	return viewCommand;
#endif
	
	return nil;
}

+ (void)registerClass:(Class)commandClass
{
	if(!commandClass) return;
	if([registeredCommands containsObject:commandClass]) return;
	[registeredCommands addObject:commandClass];
}


- (void)setArgumentsString:(NSString *)argumentsString
{
	_argumentsString = [argumentsString copy];
	
	NSString *unescape = [_argumentsString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSArray *pair = [unescape componentsSeparatedByString:@"&"];
	NSMutableDictionary *dict = [NSMutableDictionary new];
	for(NSString *p in pair) {
		NSArray *pp = [p componentsSeparatedByString:@"="];
		if([pp count] != 2) {
			NSLog(@"API (%@): Bad Argument: pair is odd.", self.api);
			continue;
		}
		[dict setObject:pp[1] forKey:pp[0]];
	}
	self.arguments = dict;
	
#if ENABLE_JSON_LOG
	NSMutableArray *array = [NSMutableArray new];
	for(NSString *p in pair) {
		NSArray *pp = [p componentsSeparatedByString:@"="];
		if([pp count] != 2) {
			NSLog(@"API (%@): Bad Argument: pair is odd.", self.api);
			continue;
		}
		[array addObject:@{@"key": pp[0], @"value": pp[1]}];
	}
	self.argumentArray = array;
#endif
}
- (NSString *)argumentsString
{
	return [_argumentsString copy];
}

- (void)setJsonData:(NSData *)jsonData
{
	NSError *error = nil;
	id json = [NSJSONSerialization JSONObjectWithData:jsonData
											  options:NSJSONReadingAllowFragments
												error:&error];
	if(error) {
		[[NSApp delegate] logLineReturn:@"\e[1m\e[31mFail decode JSON data\e[39m\e[22m %@", error];
		return;
	}
	if(![json isKindOfClass:[NSDictionary class]]) {
		[self log:@"JSON is NOT NSDictionary."];
		return;
	}
	if(![[json objectForKey:@"api_result"] isEqual:@1]) {
		[self log:@"API result is fail."];
		return;
	}
	self.json = json;
	
#if ENABLE_JSON_LOG
	self.jsonTree = @[[HMJSONNode nodeWithJSON:json]];
#endif
}
- (NSData *)jsonData
{
	return _jsonData;
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
		[object setValue:value forKey:key];
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
	
	for(NSDictionary *type in api_data) {
		NSString *stypeID = type[@"api_id"];
		NSError *error = nil;
		id result = [serverDataStore objectsWithEntityName:entityName error:&error predicateFormat:@"id = %@", stypeID];
		if(error) {
			[self log:@"Fetch error: %@", error];
			continue;
		}
		NSManagedObject *object = nil;
		if(!result || [result count] == 0) {
			object = [NSEntityDescription insertNewObjectForEntityForName:entityName
												   inManagedObjectContext:managedObjectContext];
		} else {
			object = result[0];
		}
		
		for(NSString *key in type) {
			if([self.ignoreKeys containsObject:key]) continue;
			
			id value = type[key];
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
	[self finishOperating:managedObjectContext];
	
	[managedObjectContext save:NULL];
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
