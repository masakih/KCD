//
//  HMPowerUpSupportViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/23.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMPowerUpSupportViewController: NSViewController
{
	override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	class func create() -> HMPowerUpSupportViewController? {
		return HMPowerUpSupportViewController(nibName: "HMPowerUpSupportViewController", bundle: nil)
	}
	
	override func awakeFromNib() {
		changeCategory(nil)
		
		shipController!.fetchWithRequest(nil, merge: true, error: nil)
		shipController!.sortDescriptors = HMUserDefaults.hmStandardDefauls().powerupSupportSortDecriptors
		shipController!.addObserver(self, forKeyPath: NSSortDescriptorsBinding, options: .Initial, context: nil)
	}
	
	override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
		switch keyPath {
		case NSSortDescriptorsBinding:
			HMUserDefaults.hmStandardDefauls().powerupSupportSortDecriptors = shipController!.sortDescriptors
		default:
			super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
		}
	}
	
	var managedObjectContext: NSManagedObjectContext? {
		return HMServerDataStore.defaultManager().managedObjectContext
	}
	
	var hideMaxKaryoku: Bool {
		return HMUserDefaults.hmStandardDefauls().hideMaxKaryoku
	}
	var hideMaxRaisou: Bool {
		return HMUserDefaults.hmStandardDefauls().hideMaxRaisou
	}
	var hideMaxTaiku: Bool {
		return HMUserDefaults.hmStandardDefauls().hideMaxTaiku
	}
	var hideMaxSoukou: Bool {
		return HMUserDefaults.hmStandardDefauls().hideMaxSoukou
	}
	var hideMaxLucky: Bool {
		return HMUserDefaults.hmStandardDefauls().hideMaxLucky
	}
	
	func omitPredicate() -> NSPredicate? {
		var hideKeys:[String] = []
		if hideMaxKaryoku {
			hideKeys += ["isMaxKaryoku != TRUE"]
		}
		if hideMaxRaisou {
			hideKeys += ["isMaxRaisou != TRUE"]
		}
		if hideMaxTaiku {
			hideKeys += ["isMaxTaiku != TRUE"]
		}
		if hideMaxSoukou {
			hideKeys += ["isMaxSoukou != TRUE"]
		}
		if hideMaxLucky {
			hideKeys += ["isMaxLucky != TRUE"]
		}
		if hideKeys.count == 0 { return nil }
		
		let predicateString = " AND ".join(hideKeys)
		return NSPredicate(format: predicateString, argumentArray: nil)
	}
	
	
	@IBOutlet var shipController: NSArrayController?
	@IBOutlet var typeSegment: NSSegmentedControl?
	
	@IBAction func changeCategory(sender: AnyObject?) {
		let tag = typeSegment!.selectedSegment
		if tag == -1 { return }
		let appDelegate = NSApplication.sharedApplication().delegate as HMAppDelegate
		let type = HMShipType(rawValue: tag)
		if type == nil { return }
		let catPredicate = appDelegate.predicateForShipType(type!)
		var predicate = omitPredicate()
		if predicate != nil && catPredicate != nil {
			predicate = NSCompoundPredicate.andPredicateWithSubpredicates([predicate!, catPredicate!])
		} else if catPredicate != nil {
			predicate = catPredicate
		}
		shipController!.filterPredicate = predicate
	}
}


