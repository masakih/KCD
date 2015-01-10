//
//  HMKenzoDockStatus.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/05.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMKenzoDockStatus: NSObject {
	init(dockNumber: Int) {
		assert(0 < dockNumber && dockNumber < 5, "dockNumber is out of range")
		
		controller = NSArrayController()
		self.dockNumber = dockNumber
		super.init()
		
		controller.managedObjectContext = HMServerDataStore.defaultManager().managedObjectContext
		controller.entityName = "KenzoDock"
		controller.fetchPredicate = NSPredicate(format: "id = \(dockNumber)")
		controller.automaticallyRearrangesObjects = true
		controller.fetch(nil)
		
		controller.addObserver(self, forKeyPath: "selection.state", options: .Initial, context: nil)
	}
	
	enum KenzoDockStatus: Int {
		case noShip = 0
		case hasShip = 2
		case complete = 3
		case notOpen = -1
	}
	
	let dockNumber: Int
	let controller: NSArrayController
	
	dynamic var time: NSNumber? = nil
	var tasking: Bool = false
	var didNotify: Bool = false
	var managedObjectContext: NSManagedObjectContext? = nil
	
	override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
		switch keyPath {
		case "selection.state":
			if let state = controller.valueForKeyPath("selection.state")?.integerValue {
				if let status = KenzoDockStatus(rawValue: state) {
					switch status {
					case .noShip:
						fallthrough
					case .notOpen:
						tasking = false
						didNotify = false
					case .hasShip:
						fallthrough
					case .complete:
						tasking = true
					}
				} else {
					NSLog("Kenzo Dock status is %ld", state)
				}
			}
		default:
			super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
		}
	}
	
	func update() {
		if !tasking {
			time = nil
			return
		}
		if let compTimeValue = controller.valueForKeyPath("selection.complete_time") as? NSNumber {
			let compTime: NSTimeInterval = ceil(compTimeValue.doubleValue / 1000.0)
			let now = NSDate(timeIntervalSinceNow: 0)
			let diff: NSTimeInterval = compTime - now.timeIntervalSince1970
			if diff < 0 {
				time = 0
			} else {
				time = diff
			}
			
			if !didNotify {
				if diff <= 0 {
					let notification = NSUserNotification()
					let format = NSLocalizedString("It Will Finish Build at No.%@.", comment: "It Will Finish Build at No.%@.")
					notification.title = NSString(format: format, NSNumber(integer: dockNumber))
					notification.informativeText = notification.title
					if HMUserDefaults.hmStandardDefauls().playFinishKenzoSound {
						notification.soundName = NSUserNotificationDefaultSoundName
					}
					NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
					didNotify = true
				}
			}
		} else {
			time = nil
		}
	}
}
