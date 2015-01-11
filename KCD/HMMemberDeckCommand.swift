//
//  HMMemberDeckCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/10.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

/*
mission_0:	status
0:ミッション無し
1:ミッション中
2:帰投 (おそらく帰投時のデータ確認用か帰投表示を出すため）

mission_1: maparea_id
mission_2: 帰投時間
mission_3: 未使用？
*/
class HMMemberDeckCommand: HMJSONCommand {
	required override init() {}
	
	override class func load() {
		HMJSONCommand.registerInstance(self())
	}
	override class func canExcuteAPI(api: String) -> Bool {
		if api == "/kcsapi/api_get_member/deck" { return true }
		if api == "/kcsapi/api_get_member/deck_port" { return true }
		return false
	}
	
	override var dataKey: String {
		if api == "/kcsapi/api_port/port" {
			return "api_data.api_deck_port"
		}
		if api == "/kcsapi/api_get_member/ship2" {
			return "api_data_deck"
		}
		if api == "/kcsapi/api_get_member/ship3" {
			return "api_data.api_deck_data"
		}
		return super.dataKey
	}
	override func execute() {
		super.commitJSONToEntityNamed("Deck")
	}
}
