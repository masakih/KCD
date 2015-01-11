//
//  HMMasterMapCellCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/11.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMMasterMapCellCommand: HMJSONCommand {
	override var dataKey: String {
		return "api_data.api_mst_mapcell"
	}
	override var ignoreKeys: [AnyObject] {
		return ["api_req_shiptype", "api_link_no"]
	}
	override func execute() {
		super.commitJSONToEntityNamed("MasterMapCell")
	}
}
