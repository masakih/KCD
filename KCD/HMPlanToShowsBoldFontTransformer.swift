//
//  HMPlanToShowsBoldFontTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/21.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMPlanToShowsBoldFontTransformer: NSValueTransformer
{
	override class func load() {
		NSValueTransformer.setValueTransformer(HMPlanToShowsBoldFontTransformer(), forName: "HMPlanToShowsBoldFontTransformer")
	}
	
	override class func transformedValueClass() -> AnyClass {
		return NSNumber.self
	}
	
	override class func allowsWeakReference() -> Bool { return false }
	
	override func transformedValue(value: AnyObject?) -> AnyObject? {
		let numValue = value as? NSNumber
		if numValue == nil {
			return false
		}
		
		if !HMUserDefaults.hmStandardDefauls().showsPlanColor {
			return false
		}
		if numValue == 0 {
			return false
		}
		return true
	}
	
}
