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
	
	var path: String?
	var version: UInt = 0
	
	var url: NSURL {
		return NSURL.fileURLWithPath(path!)!
	}
	var creationDate: NSDate {
		let fm = NSFileManager.defaultManager()
		let fileAttr: NSDictionary = fm.attributesOfItemAtPath(path!, error: nil)!
		return fileAttr.fileCreationDate()!
	}
	
	var imageUID: String {
		return path!
	}
	var imageRepresentationType: String = IKImageBrowserQuickLookPathRepresentationType
	var imageRepresentation: AnyObject {
		return path!
	}
	var imageTitle: String {
		return path!.lastPathComponent.stringByDeletingPathExtension
	}
	var imageSubtitle: String {
		return formatter!.stringFromDate(creationDate)
	}
	var imageVersion: UInt {
		return version
	}
	
	var tags: [String]? {
		get {
			var error: NSError? = nil
			var resource: AnyObject? = nil
			if !url.getResourceValue(&resource, forKey: NSURLTagNamesKey, error: &error) {
				if error != nil {
					println("get tags error -> \(error)")
				}
				return []
			}
			
			return resource as? [String]
		}
		set {
			var error: NSError? = nil
			url.setResourceValue(newValue, forKey: NSURLTagNamesKey, error: &error)
			if error != nil {
				println("set tags error -> \(error)")
			}
		}
	}
	
	override var hash: Int {
		return path!.hash
	}
	override func isEqual(object: AnyObject?) -> Bool {
		return path!.isEqual(object)
	}
}
