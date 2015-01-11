//
//  HMMasterFurnitureCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/11.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMMasterFurnitureCommand: HMJSONCommand {
	override var dataKey: String {
		return "api_data.api_mst_furniture"
	}
	override var ignoreKeys: [AnyObject] {
		return ["api_season"];
	}
	override func execute() {
		super.commitJSONToEntityNamed("MasterFurniture")
	}
}
