//
//  HMLocalDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/02.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Foundation

private var options: [NSObject : AnyObject]? = nil
/**
サーバーサイドには存在しないデータを保存する
*/
class HMLocalDataStore: HMCoreDataManager {
	required init(type: HMCoreDataManagerType) {
		if options == nil {
			let param = NSDictionary(object: "MEMORY", forKey: "journal_mode")
			options = [
				NSSQLitePragmasOption : param,
				NSMigratePersistentStoresAutomaticallyOption : true,
				NSInferMappingModelAutomaticallyOption : true
			]
		}
		super.init(type: type)
	}
	
	override func modelName() -> String {
		return "LocalData"
	}
	override func storeFileName() -> String {
		return "LocalData.storedata"
	}
	override func storeType() -> String {
		return NSSQLiteStoreType
	}
	override func storeOptions() -> [NSObject : AnyObject]? {
		return options
	}
	override func deleteAndRetry() -> Bool {
		return false
	}
}
