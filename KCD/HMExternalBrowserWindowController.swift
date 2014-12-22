//
//  HMExternalBrowserWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/21.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa
import WebKit

class HMExternalBrowserWindowController: NSWindowController
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
	class func create() -> HMExternalBrowserWindowController {
		return HMExternalBrowserWindowController(windowNibName: "HMExternalBrowserWindowController")
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()
		
		goHome(nil)
		webView!.addObserver(self, forKeyPath: "canGoBack", options: .Initial, context: nil)
		webView!.addObserver(self, forKeyPath: "canGoForward", options: .Initial, context: nil)
		
    }
	
	override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
		switch keyPath {
		case "canGoBack":
			goSegment!.setEnabled(webView!.canGoBack, forSegment: 0)
		case "canGoForward":
			goSegment!.setEnabled(webView!.canGoForward, forSegment: 1)
		default:
			super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
		}
	}
	
	@IBOutlet var webView: WebView?
	@IBOutlet var goSegment: NSSegmentedControl?
	
	@IBAction func reloadContent(sender: AnyObject?) {
		webView!.reload(sender)
	}
	
	@IBAction func goHome(sender: AnyObject?) {
		webView!.mainFrameURL = "http://www.dmm.com/netgame/-/basket/"
	}
	
	@IBAction func clickGoBackSegment(sender: AnyObject?) {
		let cell = goSegment!.cell() as NSSegmentedCell
		let tag = cell.tagForSegment(cell.selectedSegment)
		switch tag {
		case 0:
			webView!.goBack(sender)
		case 1:
			webView!.goForward(sender)
		default:
			break
		}
	}
}
