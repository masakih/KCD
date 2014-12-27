//
//  HMScreenshotListWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/25.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa
import Quartz

class HMScreenshotListWindowController: NSWindowController, NSSharingServiceDelegate, NSSharingServicePickerDelegate
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
	
	class func create() -> HMScreenshotListWindowController {
		let result =  HMScreenshotListWindowController(windowNibName: "HMScreenshotListWindowController")
		result.loadWindow()
		return result
	}

	var screenshots:[HMScreenshotInformation] = [] {
		willSet {
			willChangeValueForKey("screenshots")
		}
		didSet {
			didChangeValueForKey("screenshots")
		}
	}
	var deletedPaths:[HMCacheVersionInfo] = []
	var selectedIndexes: NSIndexSet? {
		willSet {
			willChangeValueForKey("selectedIndexes")
		}
		didSet {
			didChangeValueForKey("selectedIndexes")
		}
	}
	
	var screenshotSaveDirectoryPath: String {
		let appDelegate = NSApplication.sharedApplication().delegate as HMAppDelegate
		let parentDirectory = appDelegate.screenShotSaveDirectory
		let localizedInfoDictionary = NSBundle.mainBundle().localizedInfoDictionary
		let saceDirectoryName = localizedInfoDictionary!["CFBundleName"] as? String
		let path = parentDirectory.stringByAppendingPathComponent(saceDirectoryName!)
		let fm = NSFileManager.defaultManager()
		var isDir: ObjCBool = false
		var error: NSError? = nil
		if !fm.fileExistsAtPath(path, isDirectory: &isDir) {
			if !fm.createDirectoryAtPath(path, withIntermediateDirectories: false, attributes: nil, error: &error) {
				println("Can not create screenshot save directory.")
				return parentDirectory
			}
		} else if !isDir {
			println("\(path) is regular file, not directory")
			return parentDirectory
		}
		
		return path
	}
	
	override func awakeFromNib() {
		browser.setCanControlQuickLookPanel(true)
		shareButton.sendActionOn(Int(NSEventMask.LeftMouseDownMask.rawValue))
		
		screenshotsController.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_MSEC))), dispatch_get_main_queue()) {
			[unowned self] in
			self.reloadData(nil)
		}
	}
	
	func reloadData() {
		var error: NSError? = nil
		let files = NSFileManager.defaultManager().contentsOfDirectoryAtPath(screenshotSaveDirectoryPath, error: &error) as? [String]
		if error != nil {
			println(__FUNCTION__, ": error -> \(error!)")
			return
		}
		let paths = files!.map() { self.screenshotSaveDirectoryPath.stringByAppendingPathComponent($0) }
		let imageTypes = NSImage.imageTypes() as [String]
		let ws = NSWorkspace.sharedWorkspace()
		let screenshotNames = paths.filter() {
			if let type = ws.typeOfFile($0, error: &error) {
				if contains(imageTypes, type) {
					return true
				}
			}
			return false
		}
		// 無くなっているものを削除
		var currentArray = screenshots.filter() {
			if !contains(screenshotNames, $0.path) {
				self.incrementCacheVersionForPath($0.path)
				return false
			}
			return true
		}
		// 新しいものを追加
		var newNames = screenshotNames.filter() {
			f in
			let b = self.screenshots.filter() { $0.path == f }
			return b.count == 0
		}
		currentArray += newNames.map() { HMScreenshotInformation(path: $0) }
		
		screenshots = currentArray
		
		if selectedIndexes == nil {
			selectedIndexes = NSIndexSet(index: 0)
		}
	}
	func registerScreenshot(image: NSBitmapImageRep, fromOnScreen: NSRect) {
		let imageData = image.representationUsingType(NSBitmapImageFileType.NSJPEGFileType, properties: [:])
		if imageData == nil {
			println("Can not create image data.")
			NSBeep()
			return
		}
		let infoList = NSBundle.mainBundle().localizedInfoDictionary
		var filename = infoList!["CFBundleName"] as? String
		if filename == nil || filename!.isEmpty {
			filename = "KCD"
		}
		filename = filename!.stringByAppendingPathExtension("jpg")
		var path = screenshotSaveDirectoryPath.stringByAppendingPathComponent(filename!)
		path = NSFileManager.defaultManager()._web_pathWithUniqueFilenameForPath(path)
		
		imageData!.writeToFile(path, atomically: true)
		let info = HMScreenshotInformation(path: path)
		info.version = cacheVersionForPath(path)
		screenshotsController.insertObject(info, atArrangedObjectIndex: 0)
		screenshotsController.setSelectedObjects([info])
		
		if HMUserDefaults.hmStandardDefauls().showsListWindowAtScreenshot {
			window!.makeKeyAndOrderFront(nil)
		}
		
	}
	func incrementCacheVersionForPath(fullpath: String) {
		let match = deletedPaths.filter() { fullpath == $0.fullpath }
		if match.count == 0 {
			let info = HMCacheVersionInfo(path: fullpath)
			info.version = 1
			deletedPaths += [info]
		} else {
			match[0].version += 1
		}
	}
	func cacheVersionForPath(fullpath: String) -> Int {
		let match = deletedPaths.filter() { fullpath == $0.fullpath }
		return match.count == 0 ? 0 : match[0].version
	}
	
	@IBOutlet var browser: IKImageBrowserView!
	@IBOutlet var contextMenu: NSMenu!
	@IBOutlet var screenshotsController: NSArrayController!
	
	@IBAction func reloadData(sender: AnyObject?) {
		reloadData()
	}
	@IBAction func delete(sender: AnyObject?) {
		let imagePath = screenshotsController.valueForKeyPath("selection.path") as? String
		if imagePath == nil { return }
		let script = [
			"tell application \"Finder\"\n",
			"move ( \"",
			imagePath,
			"\" as POSIX file) to trash\n",
			"end tell",
			].reduce("") { $0 + $1! }
		if let appleScript = NSAppleScript(source: script) as NSAppleScript? {
			appleScript.executeAndReturnError(nil)
			let selectionIndex = screenshotsController.selectionIndex
			screenshotsController.removeObjectAtArrangedObjectIndex(selectionIndex)
			incrementCacheVersionForPath(imagePath!)
		} else {
			println("can not create AppleScript")
		}
	}
	@IBAction func revealInFinder(sender: AnyObject?) {
		let imagePath = screenshotsController.valueForKeyPath("selection.path") as? String
		if imagePath == nil { return }
		NSWorkspace.sharedWorkspace().selectFile(imagePath!, inFileViewerRootedAtPath: "")
	}
	
	// MARK: - Tweet
	var appendKanColleTag: Bool {
		get {
			return HMUserDefaults.hmStandardDefauls().appendKanColleTag
		}
		set {
			HMUserDefaults.hmStandardDefauls().appendKanColleTag = newValue
		}
	}
	var tagString: String = {
		return " #" + NSLocalizedString("kancolle", comment: "kancolle twitter hash tag")
	}()
	var useMask: Bool {
		get {
			return HMUserDefaults.hmStandardDefauls().useMask
		}
		set {
			HMUserDefaults.hmStandardDefauls().useMask = newValue
		}
	}
	
	
	@IBOutlet var maskSelectView: HMMaskSelectView!
	@IBOutlet var shareButton: NSButton!
	
	@IBAction func share(sender: AnyObject?) {
		let rect = sender?.bounds
		if rect == nil { return }
		let imagePath = screenshotsController.valueForKeyPath("selection.path") as? String
		if imagePath == nil {
			NSBeep()
			return
		}
		let image = NSImage(contentsOfFile: imagePath!)
		if image == nil {
			NSBeep()
			return
		}
		var items:[AnyObject] = [image!]
		if appendKanColleTag {
			items += [" \n" + tagString]
		}
		let picker = NSSharingServicePicker(items: items)
		picker.delegate = self
		picker.showRelativeToRect(rect!, ofView: sender! as NSView, preferredEdge: NSMinXEdge)
	}
	
	// MARK: - IKImageBrowserDelegate
	override func imageBrowser(aBrowser: IKImageBrowserView!, cellWasRightClickedAtIndex index: Int, withEvent event: NSEvent!) {
		NSMenu.popUpContextMenu(contextMenu, withEvent: event, forView: aBrowser)
	}
	
	// MARK: mark - NSSharingServiceDelegate NSSharingServicePickerDelegate
	func sharingServicePicker(sharingServicePicker: NSSharingServicePicker, delegateForSharingService sharingService: NSSharingService) -> NSSharingServiceDelegate? {
		return self
	}
	func sharingService(sharingService: NSSharingService, sourceFrameOnScreenForShareItem item: NSPasteboardWriting) -> NSRect {
		if item is String { return NSZeroRect }
		let frame = maskSelectView.frame
		return window!.convertRectToScreen(frame)
	}
	func sharingService(sharingService: NSSharingService, transitionImageForShareItem item: NSPasteboardWriting, contentRect: UnsafeMutablePointer<NSRect>) -> NSImage? {
		if item is NSImage { return item as? NSImage }
		return nil
	}
	func sharingService(sharingService: NSSharingService, sourceWindowForShareItems items: [AnyObject], sharingContentScope: UnsafeMutablePointer<NSSharingContentScope>) -> NSWindow? {
		return window!
	}

}

