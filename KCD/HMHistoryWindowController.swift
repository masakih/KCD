//
//  HMHistoryWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/21.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMHistoryWindowController: NSWindowController
{
	override init() {
		super.init()
	}
	override init(window: NSWindow?) {
		super.init(window: window)
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	class func create() -> HMHistoryWindowController {
		return HMHistoryWindowController.init(windowNibName:"HMHistoryWindowController")
	}
	
	var managedObjectContext : NSManagedObjectContext {
		return HMLocalDataStore.defaultManager().managedObjectContext
	}
	
	@IBOutlet var kaihatuHistoryController : NSArrayController?
	@IBOutlet var kenzoHistoryController : NSArrayController?
	
	var selectedTabIndex : Int = 0
	
	enum HMHistoryWindowTabIndex : Int {
		case kKaihatuHistoryIndex = 0
		case kKenzoHistoryIndex
	}
	
	@IBAction func delete(aSender: AnyObject?) {
		var sender = aSender as? NSMenuItem
		if sender == nil {
			return
		}
		
		let tag = HMHistoryWindowTabIndex(rawValue: sender!.tag)!
		var target : NSArrayController? = nil
		switch tag {
		case .kKaihatuHistoryIndex:
			target = kaihatuHistoryController
		case .kKenzoHistoryIndex:
			target = kenzoHistoryController
		}
		
		if target == nil {
			return
		}
		
		let original = target!.selectedObjects
		let objectIds = NSMutableArray()
		for object in original {
			objectIds.addObject(object.objectID)
		}
		
		let store = HMLocalDataStore.oneTimeEditor()
		let moc = store.managedObjectContext
		
		for objectID in objectIds {
			let object = moc.objectWithID(objectID as NSManagedObjectID)
			moc.deleteObject(object)
		}
	}
}
