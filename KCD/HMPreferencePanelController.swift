//
//  HMPreferencePanelController.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/23.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMPreferencePanelController: NSWindowController
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
	
	class func create() -> HMPreferencePanelController {
		return HMPreferencePanelController(windowNibName: "HMPreferencePanelController")
	}
	
	override func awakeFromNib() {
		let appDelegate = NSApplication.sharedApplication().delegate as HMAppDelegate
		screenShotSaveDirectory = appDelegate.screenShotSaveDirectory
	}
	
	enum HMPopUpMenuItemTag: Int {
		case save = 1000
		case select = 2000
	}
	
	var screenShotSaveDirectory: String {
		get {
			let appDelegate = NSApplication.sharedApplication().delegate as HMAppDelegate
			return appDelegate.screenShotSaveDirectory
		}
		set {
			let appDelegate = NSApplication.sharedApplication().delegate as HMAppDelegate
			appDelegate.screenShotSaveDirectory = newValue
			
			let index = screenShotSaveDirectoryPopUp?.indexOfItemWithTag(HMPopUpMenuItemTag.save.rawValue)
			if index == nil { return }
			let item: NSMenuItem? = screenShotSaveDirectoryPopUp?.itemAtIndex(index!)
			
			let ws = NSWorkspace.sharedWorkspace()
			let icon = ws.iconForFile(newValue)
			let iconSize: NSSize = icon.size
			let height: CGFloat = 16
			icon.size = NSMakeSize(iconSize.width * height / iconSize.height, height)
			
			let fm = NSFileManager.defaultManager()
			let title = fm.displayNameAtPath(newValue)
			
			item?.image = icon
			item?.title = title
		}
	}
	
	@IBOutlet var screenShotSaveDirectoryPopUp: NSPopUpButton?
	
	@IBAction func selectScreenShotSaveDirectoryPopUp(sender: AnyObject?) {
		let tag = sender?.tag?()
		if tag == nil || tag! != HMPopUpMenuItemTag.select.rawValue { return }
		let panel = NSOpenPanel()
		panel.canChooseDirectories = true
		panel.canChooseFiles = false
		panel.beginSheetModalForWindow(window!) {
			result in
			self.screenShotSaveDirectoryPopUp?.selectItemWithTag(HMPopUpMenuItemTag.save.rawValue)
			if result == NSCancelButton { return }
			if let path = panel.URL?.path {
				self.screenShotSaveDirectory = path
			}
		}
	}
}
