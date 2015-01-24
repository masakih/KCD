//
//  HMBroserWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/23.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa
import WebKit

class HMBroserWindowController: NSWindowController
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
	
	class func create() -> HMBroserWindowController {
		return HMBroserWindowController(windowNibName: "HMBroserWindowController")
	}
	
	override func awakeFromNib() {
		let clip = NSClipView(frame: placeholder.frame)
		clip.autoresizingMask = placeholder.autoresizingMask
		placeholder.superview?.replaceSubview(placeholder, with: clip)
		clip.documentView = webView
		
		adjustFlash()
		
		selectedViewController = HMDocksViewController.create()
		selectedViewController!.view.frame = docksPlaceholder.frame
		selectedViewController!.view.autoresizingMask = docksPlaceholder.autoresizingMask
		docksPlaceholder.superview?.replaceSubview(docksPlaceholder, with: selectedViewController!.view)
		controllers[.schedule] = selectedViewController!
		
		deckViewController = HMDeckViewController.create()
		deckViewController!.view.frame = deckPlaceholder.frame
		deckViewController!.view.autoresizingMask = deckPlaceholder.autoresizingMask
		deckPlaceholder.superview?.replaceSubview(deckPlaceholder, with: deckViewController!.view)
		
		webView.mainFrame.frameView.allowsScrolling = false
		webView.applicationNameForUserAgent = "Version/7.1 Safari/537.85.10"
		webView.mainFrameURL = "http://www.dmm.com/netgame/social/-/gadgets/=/app_id=854854/"
//		webView.mainFrameURL = "http://www.google.com/"
		
		self.bind("flagShipID", toObject: deckContoller, withKeyPath: "selection.ship_0", options: nil)
		self.bind("maxChara", toObject: basicController, withKeyPath: "selection.max_chara", options: nil)
		self.bind("shipCount", toObject: shipController, withKeyPath: "arrangedObjects.@count", options: nil)
	}
	
	
	var managedObjectContext: NSManagedObjectContext? {
		return HMServerDataStore.defaultManager().managedObjectContext
	}
	
	enum ViewType: Int {
		case schedule = 0
		case organize = 1
		case powerUp = 2
	}
	
	var controllers: [ViewType: NSViewController] = [:]
	var selectedViewsSegment: Int = 0
	var maxChara: NSNumber = 0
	var shipCount: NSNumber = 0
	var flagShipID: NSNumber = 0
	var flashTopLeft: NSPoint = NSMakePoint(70, 145)
	
	var deckViewController: HMDeckViewController?
	var selectedViewController: NSViewController?
	
	
	var minimumColoredShipCount: Int {
		get {
			return HMUserDefaults.hmStandardDefauls().minimumColoredShipCount
		}
		set {
			HMUserDefaults.hmStandardDefauls().minimumColoredShipCount = newValue
		}
	}
	var flagShipName: String? {
		var error: NSError? = nil
		let store = HMServerDataStore.defaultManager()
		let predicate = NSPredicate(format: "id = %@", argumentArray: [flagShipID])
		let array = store.objectsWithEntityName("Ship", predicate: predicate, error: &error)
		if error != nil {
			println(__FUNCTION__, ": \(error!)")
			return nil
		}
		if array.count == 0 {
			return nil
		}
		let fsName = array[0].valueForKeyPath("master_ship.name") as? String
		return fsName
	}
	var shipNumberColor: NSColor {
		let current:Int = shipCount.integerValue
		let max:Int = maxChara.integerValue
		if current > max - minimumColoredShipCount {
			return NSColor.orangeColor()
		}
		return NSColor.controlTextColor()
	}
	var linksString: NSAttributedString? {
		let url = NSBundle.mainBundle().URLForResource("Links", withExtension: "rtf")
		if url == nil { return nil }
		return NSAttributedString(URL: url!, documentAttributes: nil)
	}
	
	override class func keyPathsForValuesAffectingValueForKey(key: String) -> NSSet {
		switch key {
		case "flagShipName":
			return NSSet(object: "flagShipID")
		case "shipNumberColor":
			return NSSet(array: ["maxChara", "shipCount", "minimumColoredShipCount"])
		default:
			return super.keyPathsForValuesAffectingValueForKey(key)
		}
	}
	
	func adjustFlash() {
		let clip = webView.superview as? NSClipView
		clip?.scrollToPoint(flashTopLeft)
	}
	
	func showViewWithNumber(type: ViewType) {
		var controller = controllers[type]
		if controller == nil {
			switch type {
			case .schedule:
				controller = HMDocksViewController.create()
			case .organize:
				controller = HMShipViewController.create()
			case .powerUp:
				controller = HMPowerUpSupportViewController.create()
			}
			controllers[type] = controller
		}
		if controller == selectedViewController { return }
		
		controller!.view.frame = selectedViewController!.view.frame
		controller!.view.autoresizingMask = selectedViewController!.view.autoresizingMask
		selectedViewController!.view.superview?.replaceSubview(selectedViewController!.view, with: controller!.view)
		selectedViewController = controller
		selectedViewsSegment = type.rawValue
	}
	
	@IBOutlet var webView: WebView!
	@IBOutlet var placeholder: NSView!
	@IBOutlet var docksPlaceholder: NSView!
	@IBOutlet var deckPlaceholder: NSView!
	@IBOutlet var deckContoller: NSArrayController!
	@IBOutlet var shipController: NSArrayController!
	@IBOutlet var basicController: NSArrayController!
	
	@IBAction func reloadContent(sender: AnyObject?) {
		adjustFlash()
		
		if let prevDate = HMUserDefaults.hmStandardDefauls().prevReloadDate {
			let now = NSDate(timeIntervalSinceNow: 0)
			if now.timeIntervalSinceDate(prevDate) < 1 * 60 {
				let untilDate = prevDate.dateByAddingTimeInterval(1 * 60)
				let date = NSDateFormatter.localizedStringFromDate(untilDate, dateStyle: .NoStyle, timeStyle: .MediumStyle)
				let information = NSString(format: NSLocalizedString("Reload interval is too short.\nWait until %@.", comment: ""), date)
				let alert = NSAlert()
				alert.messageText = NSLocalizedString("Reload interval is too short", comment: "")
				alert.informativeText = information
				alert.runModal()
				return
			}
		}
		webView.reload(sender)
		HMUserDefaults.hmStandardDefauls().prevReloadDate = NSDate(timeIntervalSinceNow: 0)
	}
	@IBAction func selectView(sender: AnyObject?) {
		var type: ViewType? = nil
		if let index = sender?.selectedSegment? {
			let cell = sender!.cell() as NSSegmentedCell
			type = ViewType(rawValue: cell.tagForSegment(index))
		} else if let tag = sender?.tag?() {
			type = ViewType(rawValue: tag)
		}
		if type != nil {
			showViewWithNumber(type!)
		}
	}
	@IBAction func screenShot(sender: AnyObject?) {
		if let contentView = window!.contentView as? NSView {
			var frame = contentView.convertRect(webView.visibleRect, fromView: webView)
			let screenShotBorderWidth = HMUserDefaults.hmStandardDefauls().screenShotBorderWidth
			frame = NSInsetRect(frame, -screenShotBorderWidth, -screenShotBorderWidth)
			let rep = contentView.bitmapImageRepForCachingDisplayInRect(frame)
			if rep == nil {
				println("Could not get bitmapRep.")
				NSBeep()
				return
			}
			contentView.cacheDisplayInRect(frame, toBitmapImageRep: rep!)
			let appDelegate = NSApplication.sharedApplication().delegate as HMAppDelegate
			let slwController = appDelegate.screenshotListWindowController
			slwController.registerScreenshot(rep!, fromOnScreen: contentView.convertRect(frame, toView: nil))
		}
	}

// MARK: - WebFrameLoadDelegate
	override func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
		let request = frame.dataSource?.initialRequest
		if request == nil { return }
		let url = request!.URL
		let path = url.path
		if path == nil { return }
		
		func handler(context: JSContext!, exception: JSValue!) {
			println("caught exception in evaluateScript: \(exception)")
		}
		
		if path!.hasSuffix("gadgets/ifr") {
			let context = frame.javaScriptContext
			context.exceptionHandler = handler
			let lines = [
				"var emb = document.getElementById('flashWrap');",
				"var rect = emb.getBoundingClientRect();",
				"var atop = rect.top;",
				"var aleft = rect.left;"
			]
			context.evaluateScript("".join(lines))
			let top = context.objectForKeyedSubscript("atop")
			let left = context.objectForKeyedSubscript("aleft")
			flashTopLeft = NSMakePoint(0, webView.frame.size.height)
			let x = CGFloat(left.toDouble()) as CGFloat
			let y = webView.frame.size.height - CGFloat(top.toDouble()) - 480
			flashTopLeft = NSMakePoint(x, y)
		}
		
		if path!.hasSuffix("app_id=854854") {
			let context = frame.javaScriptContext
			context.exceptionHandler = handler
			let lines = [
				"var iframe = document.getElementById('game_frame');",
				"var validIframe = 0;",
				"if(iframe) {",
				"    validIframe = 1;",
				"    var rect = iframe.getBoundingClientRect();",
				"    var atop = rect.top;",
				"    var aleft = rect.left;",
				"}"
				]
			context.evaluateScript("".join(lines))
			let validIframe = context.objectForKeyedSubscript("validIframe")?.toInt32()
			if validIframe == 0 { return }
			
			let top = context.objectForKeyedSubscript("atop")
			let left = context.objectForKeyedSubscript("aleft")
			let x = flashTopLeft.x + CGFloat(left.toDouble())
			let y = flashTopLeft.y - CGFloat(top.toDouble())
			flashTopLeft = NSMakePoint(x, y)
			adjustFlash()
		}
	}
	
	override func webView(sender: WebView!, plugInFailedWithError error: NSError!, dataSource: WebDataSource!) {
		println("Error domain -> \(error.domain), code -> \(error.code)")
		if let info = error.userInfo {
			println("Error userInfo -> \(info)")
		}
		println("localizedDescription ->\(error.localizedDescription)")
		if let b = dataSource.initialRequest.mainDocumentURL {
			println("initial Request URL -> \(b)")
		}
	}
	
// MARK: - WebUIDelegate
	override func webView(sender: WebView!, contextMenuItemsForElement element: [NSObject : AnyObject]!, defaultMenuItems: [AnyObject]!) -> [AnyObject]! {
		var items:[AnyObject] = []
		for item in defaultMenuItems {
			switch item.tag() {
			case WebMenuItemTagOpenLinkInNewWindow,
			WebMenuItemTagDownloadLinkToDisk,
			WebMenuItemTagOpenImageInNewWindow,
			WebMenuItemTagOpenFrameInNewWindow,
			WebMenuItemTagGoBack,
			WebMenuItemTagGoForward,
			WebMenuItemTagStop,
			WebMenuItemTagReload:
				break
			default:
				items += [item]
			}
		}
		return items
	}
}
