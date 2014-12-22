//
//  HMDeckViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/22.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMDeckViewController: NSViewController
{
	override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init?(coder: NSCoder) {
	    super.init(coder: coder)
	}
	
	class func create() -> HMDeckViewController? {
		return HMDeckViewController(nibName: "HMDeckViewController", bundle: nil)
	}
	
    override func awakeFromNib() {
		selectedDeck = 1
		
		supplies1!.bind("shipStatus", toObject: fleetInfo, withKeyPath: "flagShip", options: nil)
		supplies2!.bind("shipStatus", toObject: fleetInfo, withKeyPath: "secondShip", options: nil)
		supplies3!.bind("shipStatus", toObject: fleetInfo, withKeyPath: "thirdShip", options: nil)
		supplies4!.bind("shipStatus", toObject: fleetInfo, withKeyPath: "fourthShip", options: nil)
		supplies5!.bind("shipStatus", toObject: fleetInfo, withKeyPath: "fifthShip", options: nil)
		supplies6!.bind("shipStatus", toObject: fleetInfo, withKeyPath: "sixthShip", options: nil)
    }
	
	var fleetInfo: HMFleetInformation {
		let appDelegate = NSApplication.sharedApplication().delegate as HMAppDelegate
		return appDelegate.fleetInformation
	}
	
	var selectedDeck: Int = 0 {
		willSet {
			willChangeValueForKey("selectedDeck")
		}
		didSet {
			if selectedDeck != oldValue {
				fleetInfo.selectedFleetNumber = selectedDeck
			}
			didChangeValueForKey("selectedDeck")
		}
	}
	
	@IBOutlet var supplies1: HMSuppliesView?
	@IBOutlet var supplies2: HMSuppliesView?
	@IBOutlet var supplies3: HMSuppliesView?
	@IBOutlet var supplies4: HMSuppliesView?
	@IBOutlet var supplies5: HMSuppliesView?
	@IBOutlet var supplies6: HMSuppliesView?
	
	override class func keyPathsForValuesAffectingValueForKey(key: String) -> NSSet {
		var keyPaths: NSSet
		switch key {
		case "totalSakuteki":
			keyPaths = NSSet(object: "fleetInfo.totalSakuteki")
		case "totalSeiku":
			keyPaths = NSSet(object: "fleetInfo.totalSeiku")
		default:
			keyPaths = super.keyPathsForValuesAffectingValueForKey(key)
		}
		return keyPaths;
	}
	
	var totalSakuteki: NSNumber {
		return fleetInfo.totalSakuteki
	}
	var totalSeiku: NSNumber {
		return fleetInfo.totalSeiku
	}
}
