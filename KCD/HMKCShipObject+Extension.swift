//
//  HMKCShipObject.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/31.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Foundation
import CoreData

var sShortSTypeNames: [String]?
var sLevelUpExps: [NSNumber]?

extension HMKCShipObject
{
	override class func keyPathsForValuesAffectingValueForKey(key: String) -> NSSet {
		switch key {
		case "statusColor":
			return NSSet(array: ["nowhp", "maxph"])
		case "conditionColor":
			return NSSet(array: ["cond"])
		case "name":
			return NSSet(array: ["ship_id"])
		case "shortTypeName":
			return NSSet(array: ["ship_id"])
		default:
			return NSSet()
		}
	}
	
	var shortSTypeNames: [String] {
		if sShortSTypeNames != nil { return sShortSTypeNames! }
		if let url = NSBundle.mainBundle().URLForResource("STypeShortName", withExtension: "plist") {
			if let array = NSArray(contentsOfURL: url) as? [String] {
				sShortSTypeNames = array
			} else {
				println("Can not load STypeShortName.plist.")
			}
		}
		return sShortSTypeNames!
	}
	var levelUpExps: [NSNumber] {
		if sLevelUpExps != nil { return sLevelUpExps! }
		if let url = NSBundle.mainBundle().URLForResource("LevelUpExp", withExtension: "plist") {
			if let array = NSArray(contentsOfURL: url) as? [Int] {
				sLevelUpExps = array
			} else {
				println("Can not load LevelUpExp.plist.")
			}
		}
		return sLevelUpExps!
	}
	
	
	var name: String? {
		willAccessValueForKey("master_ship")
		let name = master_ship?.name
		didAccessValueForKey("master_ship")
		return name
	}
	var shortTypeName: String? {
		willAccessValueForKey("master_ship")
		let idValue = master_ship?.stype.valueForKey("id") as? NSNumber
		didAccessValueForKey("master_ship")
		if idValue == nil { return nil }
		let id = idValue!.integerValue
		if shortSTypeNames.count < id { return nil }
		return shortSTypeNames[id - 1]
	}
	var next: NSNumber? {
		willAccessValueForKey("lv")
		let lv = self.lv
		didAccessValueForKey("lv")
		willAccessValueForKey("exp")
		let exp = self.exp
		didAccessValueForKey("exp")
		
		let currentLevel = lv.integerValue
		if currentLevel >= levelUpExps.count { return nil }
		if currentLevel == 99 { return nil }
		
		var nextExp = levelUpExps[currentLevel].integerValue
		if currentLevel > 99 {
			nextExp += 1_000_000
		}
		return nextExp - exp.integerValue
	}
	
	var statusColor: NSColor {
		willAccessValueForKey("maxhp")
		let maxhp = self.maxhp.doubleValue
		didAccessValueForKey("maxhp")
		willAccessValueForKey("nowhp")
		let nowhp = self.nowhp.doubleValue
		didAccessValueForKey("nowhp")
		
		let status = nowhp / maxhp
		if status <= 0.25 {
			return NSColor.redColor()
		}
		if status <= 0.5 {
			return NSColor.orangeColor()
		}
		if status <= 0.75 {
			return NSColor.yellowColor()
		}
		return NSColor.controlTextColor()
	}
	var conditionColor: NSColor {
		return NSColor.controlTextColor()
	}
	var planColor: NSColor? {
		if !HMUserDefaults.hmStandardDefauls().showsPlanColor {
			return NSColor.controlTextColor()
		}
		willAccessValueForKey("sally_area")
		let planType = sally_area?.integerValue
		didAccessValueForKey("sally_area")
		if planType == nil { return NSColor.controlTextColor() }
		switch planType! {
		case 1:
			return HMUserDefaults.hmStandardDefauls().plan01Color
		case 2:
			return HMUserDefaults.hmStandardDefauls().plan02Color
		case 3:
			return HMUserDefaults.hmStandardDefauls().plan03Color
		default:
			return NSColor.controlTextColor()
		}
	}
	var maxFuel: NSNumber? {
		willAccessValueForKey("master_ship")
		let number = master_ship?.fuel_max
		didAccessValueForKey("master_ship")
		return number
	}
	var maxBull: NSNumber? {
		willAccessValueForKey("master_ship")
		let number = master_ship?.bull_max
		didAccessValueForKey("master_ship")
		return number
	}
	var upgradeLevel: NSNumber? {
		willAccessValueForKey("master_ship")
		let number = master_ship?.afterlv
		didAccessValueForKey("master_ship")
		return number
	}
	var upgradeExp: NSNumber? {
		let upgradeLevel = self.upgradeLevel?.integerValue
		if upgradeLevel == nil || upgradeLevel! <= 0 { return nil }
		
		var upgradeExp = levelUpExps[upgradeLevel! - 1].integerValue
		upgradeExp = upgradeExp - exp.integerValue
		if upgradeExp < 0 { upgradeExp = 0 }
		return upgradeExp
	}
	
	var isMaxKaryoku: NSNumber {
		willAccessValueForKey("master_ship")
		let defaultValue = master_ship?.houg_0?.integerValue
		didAccessValueForKey("master_ship")
		willAccessValueForKey("karyoku_1")
		let maxValue = karyoku_1?.integerValue
		didAccessValueForKey("karyoku_1")
		willAccessValueForKey("kyouka_0")
		let growth = kyouka_0?.integerValue
		didAccessValueForKey("kyouka_0")
		if defaultValue == nil || maxValue == nil || growth == nil { return 0 }
		
		return defaultValue! + growth! >= maxValue!
	}
	var isMaxRaisou: NSNumber {
		willAccessValueForKey("master_ship")
		let defaultValue = master_ship?.raig_0?.integerValue
		didAccessValueForKey("master_ship")
		willAccessValueForKey("raisou_1")
		let maxValue = raisou_1?.integerValue
		didAccessValueForKey("raisou_1")
		willAccessValueForKey("kyouka_1")
		let growth = kyouka_1?.integerValue
		didAccessValueForKey("kyouka_1")
		if defaultValue == nil || maxValue == nil || growth == nil { return 0 }
		
		return defaultValue! + growth! >= maxValue!
	}
	var isMaxTaiku: NSNumber {
		willAccessValueForKey("master_ship")
		let defaultValue = master_ship?.tyku_0?.integerValue
		didAccessValueForKey("master_ship")
		willAccessValueForKey("taiku_1")
		let maxValue = taiku_1?.integerValue
		didAccessValueForKey("taiku_1")
		willAccessValueForKey("kyouka_2")
		let growth = kyouka_2?.integerValue
		didAccessValueForKey("kyouka_2")
		if defaultValue == nil || maxValue == nil || growth == nil { return 0 }
		
		return defaultValue! + growth! >= maxValue!
	}
	var isMaxSoukou: NSNumber {
		willAccessValueForKey("master_ship")
		let defaultValue = master_ship?.souk_0?.integerValue
		didAccessValueForKey("master_ship")
		willAccessValueForKey("soukou_1")
		let maxValue = soukou_1?.integerValue
		didAccessValueForKey("soukou_1")
		willAccessValueForKey("kyouka_3")
		let growth = kyouka_3?.integerValue
		didAccessValueForKey("kyouka_3")
		if defaultValue == nil || maxValue == nil || growth == nil { return 0 }
		
		return defaultValue! + growth! >= maxValue!
	}
	var isMaxLucky: NSNumber {
		willAccessValueForKey("master_ship")
		let defaultValue = master_ship?.luck_0?.integerValue
		didAccessValueForKey("master_ship")
		willAccessValueForKey("lucky_1")
		let maxValue = lucky_1?.integerValue
		didAccessValueForKey("lucky_1")
		willAccessValueForKey("kyouka_4")
		let growth = kyouka_4?.integerValue
		didAccessValueForKey("kyouka_4")
		if defaultValue == nil || maxValue == nil || growth == nil { return 0 }
		
		return defaultValue! + growth! >= maxValue!
	}
}
