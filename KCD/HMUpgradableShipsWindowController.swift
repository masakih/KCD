//
//  HMUpgradableShipsWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/20.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMUpgradableShipsWindowController: NSWindowController
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
	
	class func create() -> HMUpgradableShipsWindowController {
		return HMUpgradableShipsWindowController(windowNibName: "HMUpgradableShipsWindowController")
	}
	
	var managedObjectContext: NSManagedObjectContext {
		return HMServerDataStore.defaultManager().managedObjectContext
	}
	
	var filterPredicate: NSPredicate? {
		if !HMUserDefaults.hmStandardDefauls().showLevelOneShipInUpgradableList {
			return NSPredicate(format: "lv != 1", argumentArray: nil)
		}
		return nil
	}
	
	var showLevelOneShipInUpgradableList: Bool {
		get {
			return HMUserDefaults.hmStandardDefauls().showLevelOneShipInUpgradableList
		}
		set {
			HMUserDefaults.hmStandardDefauls().showLevelOneShipInUpgradableList = newValue
		}
	}
	
	override class func keyPathsForValuesAffectingValueForKey(key: String) -> NSSet {
		if key == "filterPredicate" {
			return NSSet(object: "showLevelOneShipInUpgradableList")
		}
		return super.keyPathsForValuesAffectingValueForKey(key)
	}

}
