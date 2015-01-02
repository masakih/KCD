//
//  HMServerDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/02.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Foundation

private var options: [NSObject : AnyObject]? = nil

class HMServerDataStore: HMCoreDataManager {
	override init() {
		if options == nil {
			let param = NSDictionary(object: "MEMORY", forKey: "journal_mode")
			options = [
				NSSQLitePragmasOption : param,
				NSMigratePersistentStoresAutomaticallyOption : true,
				NSInferMappingModelAutomaticallyOption : true
			]
		}
		super.init()
	}
	
	override func modelName() -> String {
		return "KCD"
	}
	override func storeFileName() -> String {
		return "KCD.storedata"
	}
	override func storeType() -> String {
		return NSSQLiteStoreType
	}
	override func storeOptions() -> [NSObject : AnyObject]? {
		return options
	}
	override func deleteAndRetry() -> Bool {
		return true
	}
}
