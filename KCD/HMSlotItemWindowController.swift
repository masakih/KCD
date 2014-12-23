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
		return HMSlotItemWindowController(windowNibName: "HMSlotItemWindowController")
	}
	
	var managedObjectContext: NSManagedObjectContext {
		return HMServerDataStore.defaultManager().managedObjectContext
	}
	
	@IBOutlet var slotItemController: NSArrayController?
	
    override func awakeFromNib() {
		var error: NSError? = nil
		self.slotItemController?.fetchWithRequest(nil, merge: true, error: &error)
		self.slotItemController?.sortDescriptors = HMUserDefaults.hmStandardDefauls().slotItemSortDescriptors
		self.slotItemController?.addObserver(self, forKeyPath: NSSortDescriptorsBinding, options: .Initial, context: nil)
    }
	
	override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
		switch keyPath {
		case NSSortDescriptorsBinding:
			HMUserDefaults.hmStandardDefauls().slotItemSortDescriptors = self.slotItemController?.sortDescriptors
		default:
			super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
		}
	}
}
