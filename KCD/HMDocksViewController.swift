//
//  HMDocksViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/23.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMDocksViewController: NSViewController
{

    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		mission2Status = HMMissionStatus(deckNumber: 2)
		mission3Status = HMMissionStatus(deckNumber: 3)
		mission4Status = HMMissionStatus(deckNumber: 4)
		
		ndock1Status = HMNyukyoDockStatus(dockNumber: 1)
		ndock2Status = HMNyukyoDockStatus(dockNumber: 2)
		ndock3Status = HMNyukyoDockStatus(dockNumber: 3)
		ndock4Status = HMNyukyoDockStatus(dockNumber: 4)
		
		kdock1Status = HMKenzoDockStatus(dockNumber: 1)
		kdock2Status = HMKenzoDockStatus(dockNumber: 2)
		kdock3Status = HMKenzoDockStatus(dockNumber: 3)
		kdock4Status = HMKenzoDockStatus(dockNumber: 4)
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init?(coder: NSCoder) {
		mission2Status = HMMissionStatus(deckNumber: 2)
		mission3Status = HMMissionStatus(deckNumber: 3)
		mission4Status = HMMissionStatus(deckNumber: 4)
		
		ndock1Status = HMNyukyoDockStatus(dockNumber: 1)
		ndock2Status = HMNyukyoDockStatus(dockNumber: 2)
		ndock3Status = HMNyukyoDockStatus(dockNumber: 3)
		ndock4Status = HMNyukyoDockStatus(dockNumber: 4)
		
		kdock1Status = HMKenzoDockStatus(dockNumber: 1)
		kdock2Status = HMKenzoDockStatus(dockNumber: 2)
		kdock3Status = HMKenzoDockStatus(dockNumber: 3)
		kdock4Status = HMKenzoDockStatus(dockNumber: 4)
		
		super.init(coder: coder)
	}
	
	class func create() -> HMDocksViewController? {
		return HMDocksViewController(nibName: "HMDocksViewController", bundle: nil)
	}
	
	override func awakeFromNib() {
		mission2Status.managedObjectContext = managedObjectContext
		mission3Status.managedObjectContext = managedObjectContext
		mission4Status.managedObjectContext = managedObjectContext
		
		self.bind("deck2Time", toObject: mission2Status, withKeyPath: "time", options: nil)
		self.bind("deck3Time", toObject: mission3Status, withKeyPath: "time", options: nil)
		self.bind("deck4Time", toObject: mission4Status, withKeyPath: "time", options: nil)
		
		self.bind("mission2Name", toObject: mission2Status, withKeyPath: "name", options: nil)
		self.bind("mission3Name", toObject: mission3Status, withKeyPath: "name", options: nil)
		self.bind("mission4Name", toObject: mission4Status, withKeyPath: "name", options: nil)
		
		ndock1Status.managedObjectContext = managedObjectContext
		ndock2Status.managedObjectContext = managedObjectContext
		ndock3Status.managedObjectContext = managedObjectContext
		ndock4Status.managedObjectContext = managedObjectContext
		
		self.bind("nDock1Time", toObject: ndock1Status, withKeyPath: "time", options: nil)
		self.bind("nDock2Time", toObject: ndock2Status, withKeyPath: "time", options: nil)
		self.bind("nDock3Time", toObject: ndock3Status, withKeyPath: "time", options: nil)
		self.bind("nDock4Time", toObject: ndock4Status, withKeyPath: "time", options: nil)
		
		self.bind("nDock1ShipName", toObject: ndock1Status, withKeyPath: "name", options: nil)
		self.bind("nDock2ShipName", toObject: ndock2Status, withKeyPath: "name", options: nil)
		self.bind("nDock3ShipName", toObject: ndock3Status, withKeyPath: "name", options: nil)
		self.bind("nDock4ShipName", toObject: ndock4Status, withKeyPath: "name", options: nil)
		
		kdock1Status.managedObjectContext = managedObjectContext
		kdock2Status.managedObjectContext = managedObjectContext
		kdock3Status.managedObjectContext = managedObjectContext
		kdock4Status.managedObjectContext = managedObjectContext
		
		self.bind("kDock1Time", toObject: kdock1Status, withKeyPath: "time", options: nil)
		self.bind("kDock2Time", toObject: kdock2Status, withKeyPath: "time", options: nil)
		self.bind("kDock3Time", toObject: kdock3Status, withKeyPath: "time", options: nil)
		self.bind("kDock4Time", toObject: kdock4Status, withKeyPath: "time", options: nil)
		
		NSTimer.scheduledTimerWithTimeInterval(0.33, target: self, selector: "fire:", userInfo: nil, repeats: true)
		
		battleContoller.addObserver(self, forKeyPath: "selection", options: .Initial, context: nil)
	}
	
	let mission2Status: HMMissionStatus
	let mission3Status: HMMissionStatus
	let mission4Status: HMMissionStatus
	
	let ndock1Status: HMNyukyoDockStatus
	let ndock2Status: HMNyukyoDockStatus
	let ndock3Status: HMNyukyoDockStatus
	let ndock4Status: HMNyukyoDockStatus
	
	let kdock1Status: HMKenzoDockStatus
	let kdock2Status: HMKenzoDockStatus
	let kdock3Status: HMKenzoDockStatus
	let kdock4Status: HMKenzoDockStatus
	
	var nDock1Time: NSNumber?
	var nDock2Time: NSNumber?
	var nDock3Time: NSNumber?
	var nDock4Time: NSNumber?
	
	var nDock1ShipName: String?
	var nDock2ShipName: String?
	var nDock3ShipName: String?
	var nDock4ShipName: String?
	
	var kDock1Time: NSNumber?
	var kDock2Time: NSNumber?
	var kDock3Time: NSNumber?
	var kDock4Time: NSNumber?
	
	var deck2Time: NSNumber?
	var deck3Time: NSNumber?
	var deck4Time: NSNumber?
	
	var mission2Name: String?
	var mission3Name: String?
	var mission4Name: String?
	
	var managedObjectContext: NSManagedObjectContext? {
		return HMServerDataStore.defaultManager().managedObjectContext
	}
	
	func fire(timer: NSTimer) {
		ndock1Status.update()
		ndock2Status.update()
		ndock3Status.update()
		ndock4Status.update()
		
		kdock1Status.update()
		kdock2Status.update()
		kdock3Status.update()
		kdock4Status.update()
		
		mission2Status.update()
		mission3Status.update()
		mission4Status.update()
	}
	
	override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
		switch keyPath {
		case "selection":
			self.willChangeValueForKey("sortieString")
			self.didChangeValueForKey("sortieString")
		default:
			super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
		}
	}
	
	var battleManagedObjectController: NSManagedObjectContext? {
		return HMTemporaryDataStore.defaultManager().managedObjectContext;
	}
	var battle: NSManagedObject? {
		let store = HMTemporaryDataStore.defaultManager()
		var error: NSError? = nil
//		let array = store.objectsWithEntityName("Battle", error: &error)
		let array = store.objectsWithEntityName("Battle", sortDescriptors: nil, predicate: nil, error: &error)

		if error != nil {
			println(__FUNCTION__, " error: \(error)")
			return nil
		}
		if array.count == 0 {
			return nil
		}
		return array[0] as? NSManagedObject
	}
	var fleetName: String? {
		let store = HMServerDataStore.defaultManager()
		var error: NSError? = nil
		let deckID = battleContoller.valueForKeyPath("content.deckId") as? NSNumber
		if deckID == nil { return nil }
		let array = store.objectsWithEntityName("Deck", predicate: NSPredicate(format: "id = %@", deckID!), error: &error)
		if error != nil {
			println(__FUNCTION__, " error: \(error)")
			return nil
		}
		if array.count == 0 {
			return nil
		}
		let name: AnyObject? = array[0].valueForKey("name")
		if name == nil { return nil }
		return "\(name!)"
	}
	var areaNumber: String? {
		let area = battleContoller.valueForKeyPath("content.mapArea") as? NSNumber
		let info = battleContoller.valueForKeyPath("content.mapInfo") as? NSNumber
		if area == nil || info == nil { return nil }
		return "\(area!)-\(info!)"
	}
	var areaName: String? {
		let store = HMServerDataStore.defaultManager()
		var error: NSError? = nil
		let area = battleContoller.valueForKeyPath("content.mapArea") as? NSNumber
		let info = battleContoller.valueForKeyPath("content.mapInfo") as? NSNumber
		if area == nil || info == nil { return nil }
		let predicate = NSPredicate(format: "maparea_id = %@ AND %K = %@", area!, "no", info!)
		let array = store.objectsWithEntityName("MasterMapInfo", predicate: predicate, error: &error)
		if error != nil {
			println(__FUNCTION__, " error: \(error)")
			return nil
		}
		if array.count == 0 {
			return nil
		}
		let name: AnyObject? = array[0].valueForKey("name")
		if name == nil { return nil }
		return "\(name!)"
	}
	var sortieString: String? {
		let fName = fleetName
		let aNum = areaNumber
		let aName = areaName
		if fName == nil || aNum == nil || aName == nil { return nil }
		let format = NSLocalizedString("%@ in sortie into %@ (%@)", comment: "Sortie")
		return NSString(format: format, fName!, aName!, aNum!)
	}
	
	@IBOutlet var battleContoller: NSObjectController!
	
}
