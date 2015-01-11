//
//  HMMasterMapInfoCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/11.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMMasterMapInfoCommand: HMJSONCommand {
	override var dataKey: String {
		return "api_data.api_mst_mapinfo"
	}
	override func execute() {
		super.commitJSONToEntityNamed("MasterMapInfo")
	}
}
