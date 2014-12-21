//
//  HMTimerCountFormatter.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/21.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMTimerCountFormatter: NSFormatter
{
	override func stringForObjectValue(obj: AnyObject) -> String? {
		var timeInterval: Double = 0.0
		if let val = obj as? NSNumber {
			timeInterval = val.doubleValue
		} else if let date = obj as? NSDate {
			timeInterval = date.timeIntervalSince1970
		} else {
			let className = NSStringFromClass(self.dynamicType)
			println("HMTimerCountFormatter: obj class is /(clssName)")
			return ""
		}
		
		let hour : Int = Int(timeInterval / (60 * 60))
		timeInterval -= Double(hour * 60 * 60)
		let minutes : Int = Int(timeInterval / 60)
		timeInterval -= Double(minutes * 60)
		let seconds : Int = Int(timeInterval)
		
		return String(format: "%02ld:%02ld:%02ld", hour, minutes, seconds)
	}
}
