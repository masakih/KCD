//
//  HMMissionStatus.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/06.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMMissionStatus: NSObject {
	init(deckNumber: Int) {
		assert(1 < deckNumber && deckNumber < 5, "dockNumber is out of range")
		
		controller = NSArrayController()
		self.deckNumber = deckNumber
		super.init()
		
		controller.managedObjectContext = HMServerDataStore.defaultManager().managedObjectContext
		controller.entityName = "Deck"
		controller.fetchPredicate = NSPredicate(format: "id = \(deckNumber)")
		controller.automaticallyRearrangesObjects = true
		controller.fetch(nil)
		
		controller.addObserver(self, forKeyPath: "selection.mission_0", options: .Initial, context: nil)
	}
	
	enum MissionStatus: Int {
		case noMission = 0
		case hasMission = 1
		case finishMission = 2
		case earlyReturnMission = 3
	}
	
	let deckNumber: Int
	let controller: NSArrayController
	
	dynamic var name: String? = nil
	dynamic var time: NSNumber? = nil
	var tasking: Bool = false
	var didNotify: Bool = false
	var prevStatusFinish: Bool = false
	var managedObjectContext: NSManagedObjectContext? = nil
	
	override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
		switch keyPath {
		case "selection.mission_0":
			if let state = controller.valueForKeyPath("selection.mission_0")?.integerValue {
				if let status = MissionStatus(rawValue: state) {
					switch status {
					case .noMission:
						name = nil
						tasking = false
						didNotify = false
						prevStatusFinish = false
					case .hasMission:
						updateName()
						tasking = true
						if prevStatusFinish {
							tasking = true
						}
						prevStatusFinish = false
					case .finishMission:
						name = nil
						tasking = false
						prevStatusFinish = true
					case .earlyReturnMission:
						break
					}
				} else {
					NSLog("Mission status is %ld", state)
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
		if let compTimeValue = controller.valueForKeyPath("selection.mission_2") as? NSNumber {
			if compTimeValue == 0 { return }
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
					if let fleetName = controller.valueForKeyPath("selection.name") as? String {
						let notification = NSUserNotification()
						var format = NSLocalizedString("%@ Will Return From Mission.", comment: "%@ Will Return From Mission.")
						notification.title = NSString(format: format, fleetName)
						format = NSLocalizedString("%@ Will Return From %@.", comment: "%@ Will Return From %@.")
						notification.informativeText = NSString(format: format, fleetName, name!)
						if HMUserDefaults.hmStandardDefauls().playFinishMissionSound {
							notification.soundName = NSUserNotificationDefaultSoundName
						}
						NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
						didNotify = true
					}
				}
			}
		} else {
			name = nil
			time = nil
		}
	}
	func updateName() {
		if prevStatusFinish {
			name = nil
			time = nil
			return
		}
		
		if let mission_1 = controller.valueForKeyPath("selection.mission_1") as? NSNumber {
			let request = NSFetchRequest(entityName: "MasterMission")
			request.predicate = NSPredicate(format: "id = \(mission_1)")
			if let array = managedObjectContext?.executeFetchRequest(request, error: nil) {
				if array.count == 0 {
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.33 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
						[unowned self] in
						self.updateName()
					}
					name = "Unknown"
				} else {
					if let newName = array[0].valueForKeyPath("name") as? String {
						name = newName
					}
				}
			}
		}
	}
}
