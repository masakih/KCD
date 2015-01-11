//
//  HMMasterSTypeCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/11.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMMasterSTypeCommand: HMJSONCommand {
	override var dataKey: String {
		return "api_data.api_mst_stype"
	}
	override var ignoreKeys: [AnyObject] {
		return ["api_equip_type"]
	}
	override func execute() {
		super.commitJSONToEntityNamed("MasterSType")
	}
}
