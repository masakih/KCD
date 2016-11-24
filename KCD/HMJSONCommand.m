//
//  HMJSONCommand.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMJSONCommand.h"

#import "HMIgnoreCommand.h"
#import "HMUnknownComand.h"
#import "HMFailedCommand.h"

#import "HMAppDelegate.h"
#import "HMServerDataStore.h"

#if ENABLE_JSON_LOG
#import "HMJSONNode.h"
#import "HMCompositCommand.h"
#import "HMJSONViewCommand.h"
#endif

static NSMutableArray *registeredCommands = nil;

@interface HMJSONCommand ()

typedef NSManagedObject *(^HMObjectSearcher)(NSString *entityName, NSManagedObjectContext *managedObjectContext, NSArray *objects, NSDictionary *element);


@property (nonatomic, copy) NSString *argumentsString;
@property (nonatomic, strong) NSData *jsonData;
@property (nonatomic, strong, readwrite) NSDate *recieveDate;

@property (copy, readwrite) NSDictionary *arguments;
@property (copy, readwrite) NSString *api;
@property (copy, readwrite) id json;

#if ENABLE_JSON_LOG
@property (copy, readwrite) NSArray *jsonTree;
@property (copy, readwrite) NSArray *argumentArray;
#endif
@end

@implementation HMJSONCommand

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		registeredCommands = [NSMutableArray new];
	});
}

+ (HMJSONCommand *)commandForAPIResult:(HMAPIResponse *)apiResult
{
	HMJSONCommand *command = nil;
	
	if(!apiResult.success) {
		command = [HMFailedCommand new];
		command.api = apiResult.api;
		command.arguments = apiResult.parameter;
		command.json = apiResult.json;
		return command;
	}
	
	for(Class commandClass in registeredCommands) {
		if([commandClass canExcuteAPI:apiResult.api]) {
			command =  [commandClass new];
			command.api = apiResult.api;
			command.arguments = apiResult.parameter;
			command.json = apiResult.json;
			
            break;
		}
	}
    
	if(!command) {
		if([HMIgnoreCommand canExcuteAPI:apiResult.api]) {
			command =  [HMIgnoreCommand new];
			command.api = apiResult.api;
			command.arguments = apiResult.parameter;
			command.json = apiResult.json;
		}
	}
	if(!command) {
		command = [HMUnknownComand new];
		command.api = apiResult.api;
		command.arguments = apiResult.parameter;
		command.json = apiResult.json;
	}
    
#if ENABLE_JSON_LOG
    HMJSONViewCommand *viewCommand = [HMJSONViewCommand new];
    viewCommand.api = apiResult.api;
    viewCommand.arguments = apiResult.parameter;
    viewCommand.json = apiResult.json;
    viewCommand.argumentArray = apiResult.argumentArray;
    id json = [HMJSONNode nodeWithJSON:apiResult.json];
    if(json) {
        viewCommand.jsonTree = @[json];
    }
    viewCommand.recieveDate = apiResult.date;
    
    command = [HMCompositCommand compositCommandWithCommands:command, viewCommand, nil];
#endif
	
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
- (NSString *)primaryKey
{
	return @"id";
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
	
	[self beginRegisterObject:object];
	
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

- (NSArray<NSSortDescriptor *> *)sortDescriptors
{
    NSArray<NSString *> *keys = self.cmpositPrimaryKeys;
    if(!keys) {
        keys = @[self.primaryKey];
    }
    NSMutableArray<NSSortDescriptor *> *sortDescriptors = [NSMutableArray array];
    for(NSString *key in keys) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:key ascending:YES];
        [sortDescriptors addObject:sortDescriptor];
    }
    return [sortDescriptors copy];
}
- (HMObjectSearcher)objectSearcher
{
    __weak HMJSONCommand *weakSelf = self;
    HMObjectSearcher p = ^NSManagedObject *(NSString *entityName, NSManagedObjectContext *moc, NSArray *objects, NSDictionary *element) {
        NSRange range = NSMakeRange(0, objects.count);
        NSArray<NSString *> *keys = weakSelf.cmpositPrimaryKeys;
        if(!keys) {
            keys = @[weakSelf.primaryKey];
        }
        NSMutableDictionary<NSString *, NSString *> *apiKeys = [NSMutableDictionary dictionary];
        for(NSString *key in keys) {
            [apiKeys setObject:[NSString stringWithFormat:@"api_%@", key] forKey:key];
        }
        NSUInteger index = [objects indexOfObject:element
                                    inSortedRange:range
                                          options:NSBinarySearchingFirstEqual
                                  usingComparator:^(id obj1, id obj2) {
                                      for(NSString *key in keys) {
                                          id value1 = [obj1 valueForKey:key];
                                          if(!value1) {
                                              value1 = [obj1 objectForKey:apiKeys[key]];
                                          }
                                          if(!value1) return NSOrderedDescending;

                                          id value2 = [obj2 valueForKey:key];
                                          if(!value2) {
                                              value2 = [obj2 objectForKey:apiKeys[key]];
                                          }
                                          if(!value2) return NSOrderedAscending;
                                          
                                          NSComparisonResult result = [value1 compare:value2];
                                          if(result != NSOrderedSame) return result;
                                      }
                                      
                                      return NSOrderedSame;
                                  }];
        
        NSManagedObject *object = nil;
        if(index == NSNotFound) {
            object = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                   inManagedObjectContext:moc];
        } else {
            object = objects[index];
        }
        return object;
    };
    
    return p;
}
- (void)commitJSONToEntityNamed:(NSString *)entityName
{
    NSArray *api_data = [self.json valueForKeyPath:self.dataKey];
    if([api_data isKindOfClass:[NSDictionary class]]) {
        api_data = @[api_data];
    }
    if(![api_data isKindOfClass:[NSArray class]]) {
        [self log:@"%@ is NOT NSArray.", self.dataKey];
        return;
    }
    
    HMServerDataStore *serverDataStore = [HMServerDataStore oneTimeEditor];
    NSManagedObjectContext *managedObjectContext = [serverDataStore managedObjectContext];
    
    NSError *error = nil;
    NSArray *objects = [serverDataStore objectsWithEntityName:entityName
                                              sortDescriptors:self.sortDescriptors
                                                    predicate:nil
                                                        error:&error];
    if(error) {
        [self log:@"Fetch error: %@", error];
        return;
    }
    
    HMObjectSearcher objectSearcher = self.objectSearcher;
    for(NSDictionary *element in api_data) {
        NSManagedObject *object = objectSearcher(entityName, managedObjectContext, objects, element);
        if(object) {
            [self registerElement:element toObject:object];
        }
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

- (void)beginRegisterObject:(NSManagedObject *)object
{
	
}
- (BOOL)handleExtraValue:(id)value forKey:(NSString *)key toObject:(NSManagedObject *)object
{
	return NO;
}
- (void)finishOperating:(NSManagedObjectContext *)moc
{
	
}

@end
