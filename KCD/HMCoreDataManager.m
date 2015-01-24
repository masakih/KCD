//
//  HMCoreDataManager.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/20.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMCoreDataManager.h"

#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, HMCoreDataManagerType) {
    readerType,
    editorType,
};

@interface HMCoreDataManager ()
@property HMCoreDataManagerType	type;
@end

@implementation HMCoreDataManager

@synthesize managedObjectContext = _managedObjectContext;

+ (instancetype)defaultManager
{
	HMCoreDataManager *defaultManager = objc_getAssociatedObject(self, "defaultManager");
	
	if(defaultManager) return defaultManager;
	
	defaultManager = [self new];
	defaultManager.type = readerType;
	
	[[defaultManager managedObjectContext] setStalenessInterval:0.0];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:defaultManager
		   selector:@selector(applicationWillTerminate:)
			   name:NSApplicationWillTerminateNotification
			 object:NSApp];
	
	objc_setAssociatedObject(self, "defaultManager", defaultManager, OBJC_ASSOCIATION_RETAIN);
	return defaultManager;
}

+ (instancetype)oneTimeEditor
{
	HMCoreDataManager *result = [self new];
	result.type = editorType;
	
	return result;
}

- (void)dealloc
{
	[self saveAction:nil];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:[[self class] defaultManager]
				  name:NSManagedObjectContextDidSaveNotification
				object:self.managedObjectContext];
}

- (NSArray *)objectsWithEntityName:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate error:(NSError **)error
{
	NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:entityName];
	[req setPredicate:predicate];
	[req setSortDescriptors:sortDescriptors];
	
	NSArray *array = [self.managedObjectContext executeFetchRequest:req error:error];
	return array;
}
- (NSArray *)objectsWithEntityName:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors error:(NSError **)error predicateFormat:(NSString *)format, ...
{
	va_list ap;
	va_start(ap, format);
	NSPredicate *predicate = [NSPredicate predicateWithFormat:format arguments:ap];
	va_end(ap);
	return [self objectsWithEntityName:entityName sortDescriptors:sortDescriptors predicate:predicate error:error];
}

- (NSArray *)objectsWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate error:(NSError **)error
{
	return [self objectsWithEntityName:entityName sortDescriptors:nil predicate:predicate error:error];
}
- (NSArray *)objectsWithEntityName:(NSString *)entityName error:(NSError **)error predicateFormat:(NSString *)format, ...
{
	va_list ap;
	va_start(ap, format);
	NSPredicate *predicate = [NSPredicate predicateWithFormat:format arguments:ap];
	va_end(ap);
	return [self objectsWithEntityName:entityName sortDescriptors:nil predicate:predicate error:error];
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.masakih.KanColleLevelManager" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.masakih.KCD"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
	id managedObjectModel = objc_getAssociatedObject([self class], "managedObjectModel");
    if (managedObjectModel) {
        return managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.modelName withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	objc_setAssociatedObject([self class], "managedObjectModel", managedObjectModel, OBJC_ASSOCIATION_RETAIN);
    return managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	id persistentStoreCoordinator = objc_getAssociatedObject([self class], "persistentStoreCoordinator");
    if (persistentStoreCoordinator) {
        return persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
	NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:self.storeFileName];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
	NSPersistentStore *store = [coordinator addPersistentStoreWithType:self.storeType
														 configuration:nil
																   URL:url
															   options:self.storeOptions
																 error:&error];
    if (!store) {
		// Data Modelが更新されていたらストアファイルを削除してもう一度
		if([[error domain] isEqualToString:NSCocoaErrorDomain] && [error code] == 134130 && self.deleteAndRetry) {
			[[NSFileManager defaultManager] removeItemAtURL:url error:&error];
			store = [coordinator addPersistentStoreWithType:self.storeType
											  configuration:nil
														URL:url
													options:self.storeOptions
													  error:&error];
			if (!store) {
				[[NSApplication sharedApplication] presentError:error];
				return nil;
			}
		} else {
			[[NSApplication sharedApplication] presentError:error];
			return nil;
		}
    }
	
	objc_setAssociatedObject([self class], "persistentStoreCoordinator", coordinator, OBJC_ASSOCIATION_RETAIN);
    
    return coordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
	if(self.type == readerType) {
		NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
		if (!coordinator) {
			NSMutableDictionary *dict = [NSMutableDictionary dictionary];
			[dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
			[dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
			NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
			[[NSApplication sharedApplication] presentError:error];
			return nil;
		}
		_managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		[_managedObjectContext setPersistentStoreCoordinator:coordinator];
	} else {
		_managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
		_managedObjectContext.parentContext = [[[self class] defaultManager] managedObjectContext];
	}
	
	_managedObjectContext.undoManager = nil;
	
    return _managedObjectContext;
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
		if([NSThread isMainThread]) {
			[[NSApplication sharedApplication] presentError:error];
		} else {
			dispatch_sync(dispatch_get_main_queue(), ^{
				[[NSApplication sharedApplication] presentError:error];
			});
		}
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[self saveAction:nil];
}

#pragma mark - abstruct
- (NSString *)modelName
{
	[NSException raise:@"Abstract method" format:@"%s is abstract.", __PRETTY_FUNCTION__];
	return nil;
}
- (NSString *)storeFileName
{
	[NSException raise:@"Abstract method" format:@"%s is abstract.", __PRETTY_FUNCTION__];
	return nil;
}
- (NSString *)storeType
{
	[NSException raise:@"Abstract method" format:@"%s is abstract.", __PRETTY_FUNCTION__];
	return nil;
}
- (NSDictionary *)storeOptions
{
	[NSException raise:@"Abstract method" format:@"%s is abstract.", __PRETTY_FUNCTION__];
	return nil;
}
- (BOOL)deleteAndRetry
{
	[NSException raise:@"Abstract method" format:@"%s is abstract.", __PRETTY_FUNCTION__];
	return NO;
}

@end
