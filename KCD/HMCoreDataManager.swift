//
//  HMCoreDataManager.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/03.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

private var defaultManagers: [NSObject : NSObject]! = nil
private var _managedObjectModelStore: [NSObject : NSManagedObjectModel]! = nil
private var _persistentStoreCoordinatorStore: [NSObject : NSPersistentStoreCoordinator]! = nil

private func managedObjectModelStore() -> [NSObject : NSManagedObjectModel] {
	if _managedObjectModelStore == nil {
		_managedObjectModelStore = [:]
	}
	return _managedObjectModelStore
}
private func persistentStoreCoordinatorStore() -> [NSObject : NSPersistentStoreCoordinator] {
	if _persistentStoreCoordinatorStore == nil {
		_persistentStoreCoordinatorStore = [:]
	}
	return _persistentStoreCoordinatorStore
}

class HMCoreDataManager: NSObject {
	enum HMCoreDataManagerType {
		case reader
		case editor
	}
	
	required init(type: HMCoreDataManagerType) {
		self.type = type
		super.init()
	}
	deinit {
		saveAction(nil)
	}
	
	let type: HMCoreDataManagerType
	
	private class func defaultManagerStore() -> [NSObject : NSObject] {
		if defaultManagers == nil {
			defaultManagers = [:]
		}
		return defaultManagers
	}
	private class func storedDefaultManager<T>(type : T.Type) -> T? {
		let classname = NSStringFromClass(self)
		if let stored = defaultManagerStore()[classname] as? T {
			return stored
		}
		
		return nil
	}
	private class func storeDefaultManager<T>(type: T.Type, defaultManager: T) {
		let classname = NSStringFromClass(self)
		if let obj = defaultManager as? NSObject {
			defaultManagers[classname] = obj
		}
	}
	class func defaultManager() -> Self {
		if let stored = storedDefaultManager(self) {
			return stored
		}
		
		let defaultManager = self(type: .reader)
		defaultManager.managedObjectContext!.stalenessInterval = 0.0
		
		let nc = NSNotificationCenter.defaultCenter()
		nc.addObserverForName(
			NSApplicationWillTerminateNotification,
			object: NSApp,
			queue: NSOperationQueue.mainQueue()) {
				(notification: NSNotification!) in
				defaultManager.saveAction(nil)
		}
		
		storeDefaultManager(self, defaultManager: defaultManager)
		return defaultManager
	}
	
	class func oneTimeEditor() -> Self {
		return self(type: .editor)
	}
	
	lazy var applicationDocumentsDirectory: NSURL = {
		let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
		let appSupportURL = urls[urls.count - 1] as NSURL
		return appSupportURL.URLByAppendingPathComponent("com.masakih.KCD")
		}()
	
	lazy var managedObjectModel: NSManagedObjectModel = {
		var stored = managedObjectModelStore()[NSStringFromClass(self.dynamicType)]
		if stored != nil { return stored! as NSManagedObjectModel }
		
		let modelURL = NSBundle.mainBundle().URLForResource(self.modelName(), withExtension: "momd")!
		let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
		
		_managedObjectModelStore[NSStringFromClass(self.dynamicType)] = managedObjectModel
		
		return managedObjectModel
		}()
	
	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
		var stored = persistentStoreCoordinatorStore()[NSStringFromClass(self.dynamicType)]
		if stored != nil { return stored }
		
		// The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
		let fileManager = NSFileManager.defaultManager()
		var shouldFail = false
		var error: NSError? = nil
		var failureReason = "There was an error creating or loading the application's saved data."
		
		// Make sure the application files directory is there
		let propertiesOpt = self.applicationDocumentsDirectory.resourceValuesForKeys([NSURLIsDirectoryKey], error: &error)
		if let properties = propertiesOpt {
			if !properties[NSURLIsDirectoryKey]!.boolValue {
				failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
				shouldFail = true
			}
		} else if error!.code == NSFileReadNoSuchFileError {
			error = nil
			fileManager.createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil, error: &error)
		}
		
		// Create the coordinator and store
		var coordinator: NSPersistentStoreCoordinator? = nil
		coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.storeFileName())
		var store = coordinator!.addPersistentStoreWithType(self.storeType(), configuration: nil, URL: url, options: self.storeOptions(), error: &error)
		if store == nil {
			if error != nil && error!.domain == NSCocoaErrorDomain && error?.code == 134130 && self.deleteAndRetry() {
				fileManager.removeItemAtURL(url, error: &error)
				store = coordinator!.addPersistentStoreWithType(self.storeType(), configuration: nil, URL: url, options: self.storeOptions(), error: &error)
				if store == nil {
					NSApplication.sharedApplication().presentError(error!)
					return nil
				}
			} else {
				NSApplication.sharedApplication().presentError(error!)
			}
		}
		if coordinator != nil {
			_persistentStoreCoordinatorStore[NSStringFromClass(self.dynamicType)] = coordinator
		}
		
		return coordinator
		}()
	
	lazy var managedObjectContext: NSManagedObjectContext? = {
		var managedObjectContext: NSManagedObjectContext? = nil
		switch self.type {
		case .reader:
			let coordinator = self.persistentStoreCoordinator
			if coordinator == nil {
				return nil
			}
			managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
			managedObjectContext?.persistentStoreCoordinator = coordinator
		case .editor:
			managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
			managedObjectContext?.parentContext = self.dynamicType.defaultManager().managedObjectContext
		}
		managedObjectContext?.undoManager = nil
		
		return managedObjectContext
		}()
	
	
	@IBAction func saveAction(sender: AnyObject?) {
		if let moc = self.managedObjectContext {
			if !moc.commitEditing() {
				NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing before saving")
			}
			var error: NSError? = nil
			if moc.hasChanges && !moc.save(&error) {
				if NSThread.isMainThread() {
					NSApplication.sharedApplication().presentError(error!)
				} else {
					dispatch_sync(dispatch_get_main_queue()) {
						let e: NSError = error!
						NSApplication.sharedApplication().presentError(e)
					}
				}
			}
		}
	}
}

// MARK: - Abstruct
extension HMCoreDataManager {
	func modelName() -> String {
		assertionFailure("MUST OVERRIDE THIS")
	}
	func storeFileName() -> String {
		assertionFailure("MUST OVERRIDE THIS")
	}
	func storeType() -> String {
		assertionFailure("MUST OVERRIDE THIS")
	}
	func storeOptions() -> [NSObject : AnyObject]? {
		assertionFailure("MUST OVERRIDE THIS")
	}
	func deleteAndRetry() -> Bool {
		assertionFailure("MUST OVERRIDE THIS")
	}
}

// MARK: - CoreData Accessor
extension HMCoreDataManager {
	func objectsWithEntityName(entityName: String, sortDescriptors: [NSSortDescriptor]? = nil, predicate: NSPredicate? = nil, error: NSErrorPointer = nil) -> [AnyObject] {
		let request = NSFetchRequest(entityName: entityName)
		request.predicate = predicate
		request.sortDescriptors = sortDescriptors
		if let array = managedObjectContext?.executeFetchRequest(request, error: error) {
			return array
		}
		return []
	}
}
