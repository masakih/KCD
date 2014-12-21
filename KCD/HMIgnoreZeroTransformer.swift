//
//  HMIgnoreZeroTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/21.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMIgnoreZeroTransformer: NSValueTransformer
{
	override class func load() {
		NSValueTransformer.setValueTransformer(HMIgnoreZeroTransformer(), forName: "HMIgnoreZeroTransformer")
	}
	
	override class func transformedValueClass() -> AnyClass {
		return NSNumber.self
	}
	
	override class func allowsReverseTransformation() -> Bool { return false }
	
	override func transformedValue(value: AnyObject?) -> AnyObject? {
		let numValue = value as? NSNumber
		if numValue == nil {
			return nil
		}
		if numValue == 0 {
			return nil
		}
		return value
	}
}
