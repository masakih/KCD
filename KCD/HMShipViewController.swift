//
//  HMShipViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/23.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMShipViewController: NSViewController
{
	override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	class func create() -> HMShipViewController? {
		return HMShipViewController(nibName: "HMShipViewController", bundle: nil)
	}
	
	override func awakeFromNib() {
		currentTableView = expTableView
		
		shipController!.fetchWithRequest(nil, merge: true, error: nil)
		shipController!.sortDescriptors = HMUserDefaults.hmStandardDefauls().shipviewSortDescriptors
		shipController!.addObserver(self, forKeyPath: NSSortDescriptorsBinding, options: .Initial, context: nil)
		
		let nc = NSNotificationCenter.defaultCenter()
		nc.addObserverForName(NSScrollViewDidEndLiveScrollNotification, object: expTableView, queue: NSOperationQueue.mainQueue(), usingBlock: scrollViewDidEndLiveScrollNotification)
		nc.addObserverForName(NSScrollViewDidEndLiveScrollNotification, object: powerTableView, queue: NSOperationQueue.mainQueue(), usingBlock: scrollViewDidEndLiveScrollNotification)
		nc.addObserverForName(NSScrollViewDidEndLiveScrollNotification, object: power2TableView, queue: NSOperationQueue.mainQueue(), usingBlock: scrollViewDidEndLiveScrollNotification)
	}
	
	override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
		switch keyPath {
		case NSSortDescriptorsBinding:
			if let sortDescriptors = shipController.sortDescriptors as? [NSSortDescriptor] {
				HMUserDefaults.hmStandardDefauls().shipviewSortDescriptors = sortDescriptors
			}
		default:
			super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
		}
	}
	
	var managedObjectContext: NSManagedObjectContext? {
		return HMServerDataStore.defaultManager().managedObjectContext
	}
	
	enum ViewType: Int {
		case expView = 0
		case powerView
		case power2View
	}
	
	func showViewWithNumber(type: ViewType) {
		var newSelection: NSView? = nil
		switch type {
		case .expView:
			newSelection = expTableView
		case .powerView:
			newSelection = powerTableView
		case .power2View:
			newSelection = power2TableView
		}
		if newSelection == nil { return }
		if currentTableView == newSelection { return }
		
		newSelection!.frame = currentTableView!.frame
		newSelection!.autoresizingMask = currentTableView!.autoresizingMask
		view.replaceSubview(currentTableView!, with: newSelection!)
		currentTableView = newSelection
	}
	
	weak var currentTableView: NSView?
	
	@IBOutlet var shipController: NSArrayController!
	@IBOutlet var expTableView: NSScrollView!
	@IBOutlet var powerTableView: NSScrollView!
	@IBOutlet var power2TableView: NSScrollView!
	
	@IBAction func changeCategory(sender: AnyObject?) {
		let selectedSegment = sender?.selectedSegment?
		if selectedSegment == nil { return }
		let type = HMShipType(rawValue: selectedSegment!)
		if type == nil { return }
		let appDelegate = NSApplication.sharedApplication().delegate as HMAppDelegate
		let predicate: NSPredicate? = appDelegate.predicateForShipType(type!)
		
		shipController.filterPredicate = predicate
	}
	@IBAction func changeView(sender: AnyObject?) {
		var tag: Int? = nil
		if let index = sender?.selectedSegment? {
			let cell = sender!.cell() as NSSegmentedCell
			tag = cell.tagForSegment(index)
		} else if let control = sender as? NSControl {
			tag = control.tag
		}
		if tag == nil { return }
		if let type = ViewType(rawValue: tag!) {
			showViewWithNumber(type)
		}
	}
	
// MARK: - NSScrollViewDidEndLiveScrollNotification
	func scrollViewDidEndLiveScrollNotification(notification: NSNotification!) {
		let object = notification.object as NSScrollView?
		if object == nil { return }
		let visibleRect = object!.documentVisibleRect
		for item in [expTableView, powerTableView, power2TableView] {
			if object == item { continue }
			let view = item?.documentView as? NSView
			view?.scrollRectToVisible(visibleRect)
		}
	}

}
