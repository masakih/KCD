//
//  HMSlotItemWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/20.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa


class HMSlotItemWindowController: NSWindowController
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
	
	class func create() -> HMSlotItemWindowController {
		var hoge =  HMSlotItemWindowController.init(windowNibName:"HMSlotItemWindowController")
		return hoge
	}
	
	
	var managedObjectContext : NSManagedObjectContext {
		get {
			var store : HMServerDataStore = HMServerDataStore.defaultManager()
			return store.managedObjectContext
		}
	}
	
	@IBOutlet var slotItemController : NSArrayController?
	
	
    override func windowDidLoad() {
        super.windowDidLoad()
		
		var error : NSErrorPointer = nil
		self.slotItemController?.fetchWithRequest(nil, merge: true, error: error)
		self.slotItemController?.sortDescriptors = HMUserDefaults.hmStandardDefauls().slotItemSortDescriptors
		self.slotItemController?.addObserver(self, forKeyPath: NSSortDescriptorsBinding, options: .Initial, context: nil)
    }
	
	override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
		if keyPath == NSSortDescriptorsBinding {
			HMUserDefaults.hmStandardDefauls().slotItemSortDescriptors = self.slotItemController?.sortDescriptors
		}
		super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
	}
}
