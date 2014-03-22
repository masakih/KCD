//
//  HMCoreDataManager.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/20.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMCoreDataManager.h"

@implementation HMCoreDataManager

//@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
//@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

static HMCoreDataManager *defaultManager = nil;

static NSPersistentStoreCoordinator *_persistentStoreCoordinator = nil;
static NSManagedObjectModel *_managedObjectModel = nil;

+ (HMCoreDataManager *)defaultManager
{
	if(defaultManager) return defaultManager;
	
	defaultManager = [self new];
	[defaultManager.managedObjectContext setMergePolicy:NSRollbackMergePolicy];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:defaultManager
		   selector:@selector(applicationWillTerminate:)
			   name:NSApplicationWillTerminateNotification
			 object:NSApp];
	[nc addObserver:defaultManager
		   selector:@selector(anotherContextDidSave:)
			   name:NSManagedObjectContextDidSaveNotification
			 object:nil];
	
	return defaultManager;
}

+ (HMCoreDataManager *)oneTimeEditor
{
	// we need default manager.
	[self defaultManager];
	
	HMCoreDataManager *result = [self new];
	[result.managedObjectContext setMergePolicy:NSOverwriteMergePolicy];
	return result;
}

- (void)dealloc
{
	[self saveAction:nil];
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
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"KCD" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
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
#if COREDATA_STORE_TYPE == 0
	NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"KCD.storedata"];
	NSString *storeType = NSSQLiteStoreType;
#else
	NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"KCD.storedata.xml"];
	NSString *storeType = NSXMLStoreType;
#endif
	NSDictionary *options = @{
							  NSMigratePersistentStoresAutomaticallyOption : @YES,
							  NSInferMappingModelAutomaticallyOption : @YES
							  };
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:storeType configuration:nil URL:url options:options error:&error]) {
		// Data Modelが更新されていたらストアファイルを削除してもう一度
		if([[error domain] isEqualToString:NSCocoaErrorDomain] && [error code] == 134130) {
			[[NSFileManager defaultManager] removeItemAtURL:url error:&error];
			if (![coordinator addPersistentStoreWithType:storeType configuration:nil URL:url options:options error:&error]) {
				[[NSApplication sharedApplication] presentError:error];
				return nil;
			}
		} else {
			[[NSApplication sharedApplication] presentError:error];
			return nil;
		}
    }
	
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
	
	
	
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
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[self saveAction:nil];
}

- (void)anotherContextDidSave:(NSNotification *)notification
{
	NSManagedObjectContext *moc = [notification object];
	NSPersistentStoreCoordinator *psc = [moc persistentStoreCoordinator];
	if(![psc isEqual:_persistentStoreCoordinator]) return;
	
	if([NSThread isMainThread]) {
		[self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
	} else {
		dispatch_sync(dispatch_get_main_queue(), ^{
			[self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
		});
	}
}

@end
