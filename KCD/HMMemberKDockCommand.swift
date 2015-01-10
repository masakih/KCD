//
//  HMMemberKDockCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/10.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMMemberKDockCommand: HMJSONCommand {
	required override init() {}
	
	override class func load() {
		HMJSONCommand.registerInstance(self())
	}
	override class func canExcuteAPI(api: String) -> Bool {
		return api == "/kcsapi/api_get_member/kdock"
	}
	
	override var dataKey: String {
		if api == "/kcsapi/api_req_kousyou/getship" {
			return "api_data.api_kdock"
		}
		return super.dataKey
	}
	override func execute() {
		super.commitJSONToEntityNamed("KenzoDock")
	}
}
