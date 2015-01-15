//
//  HMResetSortieCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/15.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

/// 出撃よりの帰還時に出撃内容を消す
class HMResetSortieCommand: HMJSONCommand {
	override func execute() {
		let store = HMTemporaryDataStore.oneTimeEditor()
		var error: NSError? = nil
		let array = store.objectsWithEntityName("Battle", sortDescriptors: nil, predicate: nil, error: &error)
		if error != nil {
			NSLog("\(__FUNCTION__) error: \(error!)")
			return
		}
		let moc = store.managedObjectContext!
		for object in array {
			moc.deleteObject(object as NSManagedObject)
		}
	}
}
