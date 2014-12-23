//
//  HMCacheVersionInfo.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/23.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMCacheVersionInfo: NSObject, NSCopying
{
	init(path: String) {
		fullpath = path
		super.init()
	}
	let fullpath: String
	var version: Int = 0
	
	func copyWithZone(zone: NSZone) -> AnyObject {
		let result = HMCacheVersionInfo(path: fullpath)
		result.version = version
		return result
	}
	
	override var hash: Int {
		return fullpath.hash
	}
	override func isEqual(object: AnyObject?) -> Bool {
		if super.isEqual(object) { return true }
		let info = object as? HMCacheVersionInfo
		if info == nil { return  false }
		return fullpath.isEqual(info!.fullpath)
	}
}
