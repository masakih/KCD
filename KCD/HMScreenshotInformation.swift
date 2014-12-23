//
//  HMScreenshotInformation.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/23.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa
import Quartz

var formatter: NSDateFormatter?

class HMScreenshotInformation: NSObject
{
	override class func initialize() {
		formatter = NSDateFormatter()
		formatter?.dateStyle = .ShortStyle
		formatter?.timeStyle = .ShortStyle
		formatter?.doesRelativeDateFormatting = true
	}
	
	init(path aPath: String) {
		path = aPath
		super.init()
	}
	
	var path: String
	var version: UInt = 0
	
	lazy var url: NSURL? = {
		return NSURL.fileURLWithPath(self.path)
	}()
	lazy var creationDate: NSDate? = {
		let fm = NSFileManager.defaultManager()
		let fileAttr: NSDictionary = fm.attributesOfItemAtPath(self.path, error: nil)!
		return fileAttr.fileCreationDate()
	}()
	
	var imageUID: String {
		return path
	}
	var imageRepresentationType: String = IKImageBrowserQuickLookPathRepresentationType
	var imageRepresentation: AnyObject {
		return path
	}
	var imageTitle: String {
		return path.lastPathComponent.stringByDeletingPathExtension
	}
	var imageSubtitle: String? {
		if creationDate == nil {
			return nil
		}
		return formatter!.stringFromDate(creationDate!)
	}
	var imageVersion: UInt {
		return version
	}
	
	var tags: [String]? {
		get {
			if url == nil {
				return nil
			}
			var error: NSError? = nil
			var resource: AnyObject? = nil
			if !url!.getResourceValue(&resource, forKey: NSURLTagNamesKey, error: &error) {
				if error != nil {
					println("get tags error -> \(error)")
				}
			}
			
			return resource as? [String]
		}
		set {
			if url == nil {
				return
			}
			var error: NSError? = nil
			url!.setResourceValue(newValue, forKey: NSURLTagNamesKey, error: &error)
			if error != nil {
				println("set tags error -> \(error)")
			}
		}
	}
	
	override var hash: Int {
		return path.hash
	}
	override func isEqual(object: AnyObject?) -> Bool {
		if super.isEqual(object) { return true }
		let info = object as? HMScreenshotInformation
		if info == nil { return  false }
		return path.isEqual(object!.path)
	}
}
