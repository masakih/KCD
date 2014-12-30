//
//  HMMaskInformation.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/29.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMMaskInformation: NSObject
{
	override init() {
		super.init()
	}
	var maskRect: NSRect = NSZeroRect
	var enable: Bool = false
	var borderColor: NSColor?
	let maskColor: NSColor = NSColor.blackColor()
}
