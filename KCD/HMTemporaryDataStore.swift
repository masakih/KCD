//
//  HMTemporaryDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/02.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Foundation


class HMTemporaryDataStore: HMCoreDataManager {
	override class func load() {
		self.defaultManager()
	}
	
	override func modelName() -> String {
		return "Temporary"
	}
	override func storeFileName() -> String {
		return ":memory:"
	}
	override func storeType() -> String {
		return NSInMemoryStoreType
	}
	override func storeOptions() -> [NSObject : AnyObject]? {
		return nil
	}
	override func deleteAndRetry() -> Bool {
		return true
	}
}
