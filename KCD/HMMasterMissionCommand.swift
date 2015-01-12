//
//  HMMasterMissionCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/12.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMMasterMissionCommand: HMJSONCommand {
	override var dataKey: String {
		return "api_data.api_mst_mission"
	}
	override func execute() {
		super.commitJSONToEntityNamed("MasterMission")
	}
}
