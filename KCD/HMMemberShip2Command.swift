//
//  HMMemberShip2Command.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/12.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMMemberShip2Command: HMCompositCommand, NSCopying {
	required override init(commandArray: [AnyObject]) {
		super.init(commandArray: commandArray)
	}
	
	override class func load() {
		// Mavericksにおいてload()のタイミングでNSArrayを生成することが出来ないため、遅延させる
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_MSEC))), dispatch_get_main_queue()) {
			let prototype = self(commandArray: [HMMemberShipCommand(), HMMemberDeckCommand()])
			HMJSONCommand.registerInstance(prototype)
		}
	}
	override class func canExcuteAPI(api: String) -> Bool {
		return api == "/kcsapi/api_get_member/ship2"
	}
	
	
	override func copyWithZone(zone: NSZone) -> AnyObject {
		return self.dynamicType.init(commandArray: [HMMemberShipCommand(), HMMemberDeckCommand()])
	}
}
