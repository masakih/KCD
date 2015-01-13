//
//  HMMidnightBattleCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/13.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMMidnightBattleCommand: HMCompositCommand, NSCopying {
	required override init(commandArray: [AnyObject]) {
		super.init(commandArray: commandArray)
	}
	
	override class func load() {
		// Mavericksにおいてload()のタイミングでNSArrayを生成することが出来ないため、遅延させる
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_MSEC))), dispatch_get_main_queue()) {
			HMJSONCommand.registerInstance(self(commandArray: self.commands()))
		}
	}
	override class func canExcuteAPI(api: String) -> Bool {
		if api == "/kcsapi/api_req_battle_midnight/battle" { return true }
		if api == "/kcsapi/api_req_battle_midnight/sp_midnight" { return true }
		return false
	}
	
	override func copyWithZone(zone: NSZone) -> AnyObject {
		return self.dynamicType.init(commandArray: self.dynamicType.commands())
	}
	
	class func commands() -> [AnyObject] {
		return [HMCalculateDamageCommand()]
	}
}
