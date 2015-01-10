//
//  HMNyukyoDockStatus.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/04.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMNyukyoDockStatus: NSObject {
	init(dockNumber: Int) {
		assert(0 < dockNumber && dockNumber < 5, "dockNumber is out of range")
		
		controller = NSArrayController()
		self.dockNumber = dockNumber
		super.init()

		controller.managedObjectContext = HMServerDataStore.defaultManager().managedObjectContext
		controller.entityName = "NyukyoDock"
		controller.fetchPredicate = NSPredicate(format: "id = \(dockNumber)")
		controller.automaticallyRearrangesObjects = true
		controller.fetch(nil)
		
		controller.addObserver(self, forKeyPath: "selection.state", options: .Initial, context: nil)
	}
	
	enum NyukyoDockStatus: Int {
		case noShip = 0
		case hasShip = 1
	}
	
	let dockNumber: Int
	let controller: NSArrayController
	
	dynamic var name: String? = nil
	dynamic var time: NSNumber? = nil
	var tasking: Bool = false
	var didNotify: Bool = false
	var managedObjectContext: NSManagedObjectContext? = nil
	
	override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
		switch keyPath {
		case "selection.state":
			if let state = controller.valueForKeyPath("selection.state")?.integerValue {
				if let status = NyukyoDockStatus(rawValue: state) {
					switch status {
					case .noShip:
						name = nil
						tasking = false
						didNotify = false
					case .hasShip:
						updateName()
						tasking = true
					}
				} else {
					NSLog("Nyukyo Dock status is %ld", state)
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
				if diff < 1 * 60 {
					let notification = NSUserNotification()
					let format = NSLocalizedString("%@ Will Finish Docking.", comment: "%@ Will Finish Docking.")
					notification.title = NSString(format: format, name!)
					notification.informativeText = notification.title
					if HMUserDefaults.hmStandardDefauls().playFinishNyukyoSound {
						notification.soundName = NSUserNotificationDefaultSoundName
					}
					NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
					didNotify = true
				}
			}
		} else {
			name = nil
			time = nil
		}
	}
	func updateName() {
		if let shipID = controller.valueForKeyPath("selection.ship_id") as? NSNumber {
			if shipID.integerValue == 0 { return }
			
			let request = NSFetchRequest(entityName: "Ship")
			request.predicate = NSPredicate(format: "id = \(shipID)")
			if let array = managedObjectContext?.executeFetchRequest(request, error: nil) {
				if array.count == 0 {
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.33 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
						[unowned self] in
						self.updateName()
					}
					name = "Unknown"
				} else {
					if let newName = array[0].valueForKeyPath("master_ship.name") as? String {
						name = newName
					}
				}
			}
		}
	}
}
