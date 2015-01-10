//
//  HMMemberNDockCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/09.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMMemberNDockCommand: HMJSONCommand {
	required override init() {}
	
	override class func load() {
		HMJSONCommand.registerInstance(self())
	}
	override class func canExcuteAPI(api: String) -> Bool {
		return api == "/kcsapi/api_get_member/ndock"
	}
	
	override var dataKey: String {
		if api == "/kcsapi/api_port/port" {
			return "api_data.api_ndock"
		}
		return super.dataKey
	}
	override func execute() {
		super.commitJSONToEntityNamed("NyukyoDock")
	}
}
