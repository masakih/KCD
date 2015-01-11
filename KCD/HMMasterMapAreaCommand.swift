//
//  HMMasterMapAreaCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/11.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMMasterMapAreaCommand: HMJSONCommand {
	override var dataKey: String {
		return "api_data.api_mst_maparea"
	}
	override func execute() {
		super.commitJSONToEntityNamed("MasterMapArea")
	}
}
