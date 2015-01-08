//
//  HMUserDefaults.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/06.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Cocoa

private var _standardDefaults: HMUserDefaults!

class HMUserDefaults: NSObject {
	private override init() {
		super.init()
	}
	
	class func hmStandardDefauls() -> HMUserDefaults {
		if _standardDefaults == nil {
			_standardDefaults = HMUserDefaults()
		}
		return _standardDefaults
	}
	
	private func setObject(value: AnyObject?, forKey key: String) {
		NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
	}
	private func objectForKey(key: String) -> AnyObject? {
		return NSUserDefaults.standardUserDefaults().objectForKey(key)
	}
	private func stringForKey(key: String) -> String? {
		return NSUserDefaults.standardUserDefaults().stringForKey(key)
	}
	private func setInteger(value: Int, forKey key: String) {
		NSUserDefaults.standardUserDefaults().setInteger(value, forKey: key)
	}
	private func integerForKey(key: String) -> Int {
		return NSUserDefaults.standardUserDefaults().integerForKey(key)
	}
	private func setDouble(value: Double, forKey key: String) {
		NSUserDefaults.standardUserDefaults().setDouble(value, forKey: key)
	}
	private func doubleForKey(key: String) -> Double {
		return NSUserDefaults.standardUserDefaults().doubleForKey(key)
	}
	private func setBool(value: Bool, forKey key: String) {
		NSUserDefaults.standardUserDefaults().setBool(value, forKey: key)
	}
	private func boolForKey(key: String) -> Bool {
		return NSUserDefaults.standardUserDefaults().boolForKey(key)
	}
	private func setKeyedArchiveObject(value: AnyObject?, forKey key: String) {
		if value != nil {
			let data = NSKeyedArchiver.archivedDataWithRootObject(value!)
			setObject(data, forKey: key)
		}
	}
	private func keyedUnarchiveObject(key: String) -> AnyObject? {
		if let data = objectForKey(key) as? NSData {
			return NSKeyedUnarchiver.unarchiveObjectWithData(data)
		}
		return nil
	}
}

/// For Debug
extension HMUserDefaults {
	var showsDebugMenu: Bool {
		return boolForKey("showsDebugMenu")
	}
	
	/// 課金用のウインドウを使用可能にする
	var showsBillingWindowMenu: Bool {
		return boolForKey("showsBillingWindowMenu")
	}
}

/// SortDescriptors
extension HMUserDefaults {
	var slotItemSortDescriptors: [NSSortDescriptor] {
		get {
			if let array = keyedUnarchiveObject("slotItemSortKey2") as? [NSSortDescriptor] {
				return array.filter() {
					if let key = $0.key() {
						if key.hasPrefix("master_ship") || key.hasPrefix("master_slotItem"){
							return false
						}
					}
					return true
				}
			}
			return []
		}
		set {
			setKeyedArchiveObject(newValue, forKey: "slotItemSortKey2")
		}
	}
	var shipviewSortDescriptors: [NSSortDescriptor] {
		get {
			if let array = keyedUnarchiveObject("shipviewsortdescriptor") as? [NSSortDescriptor] {
				return array.filter() {
					if let key = $0.key() {
						if key.hasPrefix("master_ship") {
							return false
						}
					}
					return true
				}
			}
			return []
		}
		set {
			setKeyedArchiveObject(newValue, forKey: "shipviewsortdescriptor")
		}
	}
	var powerupSupportSortDecriptors: [NSSortDescriptor] {
		get {
			if let array = keyedUnarchiveObject("powerupsupportsortdecriptor") as? [NSSortDescriptor] {
				return array.filter() {
					if let key = $0.key() {
						if key.hasPrefix("master_ship") {
							return false
						}
					}
					return true
				}
			}
			return []
		}
		set {
			setKeyedArchiveObject(newValue, forKey: "powerupsupportsortdecriptor")
		}
	}
}

/// limit reload
extension HMUserDefaults {
	var prevReloadDate: NSDate? {
		get {
			if let dateString = stringForKey("previousReloadDateString") {
				return NSDate(string: dateString)
			}
			return nil
		}
		set {
			if newValue != nil {
				setObject(newValue!.description, forKey: "previousReloadDateString")
			} else {
				setObject(nil, forKey: "previousReloadDateString")
			}
		}
	}
}

/// main window
extension HMUserDefaults {
	/// 取得可能艦娘数
	var minimumColoredShipCount: Int {
		get {
			return integerForKey("minimumColoredShipCount")
		}
		set {
			setInteger(newValue, forKey: "minimumColoredShipCount")
		}
	}
}

/// Organize view
extension HMUserDefaults {

	/// 2014年夏イベント時の出撃海域による色分けの有効／無効
	var showsPlanColor: Bool {
		get {
			return boolForKey("showsPlanColor")
		}
		set {
			setBool(newValue, forKey: "showsPlanColor")
		}
	}
	/// 作戦０１の色
	var plan01Color: NSColor? {
		get {
			return keyedUnarchiveObject("plan01Color") as NSColor?
		}
		set {
			setKeyedArchiveObject(newValue, forKey: "plan01Color")
		}
	}
	/// 作戦０２の色
	var plan02Color: NSColor? {
		get {
			return keyedUnarchiveObject("plan02Color") as NSColor?
		}
		set {
			setKeyedArchiveObject(newValue, forKey: "plan02Color")
		}
	}
	/// 作戦０３の色
	var plan03Color: NSColor? {
		get {
			return keyedUnarchiveObject("plan03Color") as NSColor?
		}
		set {
			setKeyedArchiveObject(newValue, forKey: "plan03Color")
		}
	}
}

/// PowerUp view
extension HMUserDefaults {
	var hideMaxKaryoku: Bool {
		get {
			return boolForKey("hideMaxKaryoku")
		}
		set {
			setBool(newValue, forKey: "hideMaxKaryoku")
		}
	}
	var hideMaxRaisou: Bool {
		get {
			return boolForKey("hideMaxRaisou")
		}
		set {
			setBool(newValue, forKey: "hideMaxRaisou")
		}
	}
	var hideMaxTaiku: Bool {
		get {
			return boolForKey("hideMaxTaiku")
		}
		set {
			setBool(newValue, forKey: "hideMaxTaiku")
		}
	}
	var hideMaxSoukou: Bool {
		get {
			return boolForKey("hideMaxSoukou")
		}
		set {
			setBool(newValue, forKey: "hideMaxSoukou")
		}
	}
	var hideMaxLucky: Bool {
		get {
			return boolForKey("hideMaxLucky")
		}
		set {
			setBool(newValue, forKey: "hideMaxLucky")
		}
	}
}

/// Screenshot window
extension HMUserDefaults {
	/// スクリーンショットの縁取りの幅
	var screenShotBorderWidth: CGFloat {
		get {
			let result = doubleForKey("screenShotBorderWidth")
			if result < 0 { return 0 }
			if result > 20 { return 20 }
			return CGFloat(result)
		}
		set {
			if newValue < 0 || newValue > 20 { return }
			setDouble(Double(newValue), forKey: "screenShotBorderWidth")
		}
	}
	/// スクリーンショットに提督名マスクを施すか
	var useMask: Bool {
		get {
			return boolForKey("useMask")
		}
		set {
			setBool(newValue, forKey: "useMask")
		}
	}
	/// スクリーンショットを保存する場所
	var screenShotSaveDirectory: String? {
		get {
			return stringForKey("screenShotSaveDirectory")
		}
		set {
			setObject(newValue, forKey: "screenShotSaveDirectory")
		}
	}
	/// スクリーンショットを撮ったときリストウインドウを最前面にするか
	var showsListWindowAtScreenshot: Bool {
		get {
			return boolForKey("showsListWindowAtScreenshot")
		}
		set {
			setBool(newValue, forKey: "showsListWindowAtScreenshot")
		}
	}
	/// スクリーンショットのプレビューのズーム値
	var screenshotPreviewZoomValue: NSNumber? {
		get {
			return objectForKey("screenshotPreviewZoomValue") as NSNumber?
		}
		set {
			setObject(newValue, forKey: "screenshotPreviewZoomValue")
		}
	}
	
	/// ツイートに艦これタグを付けるか
	var appendKanColleTag: Bool {
		get {
			return boolForKey("appendKanColleTag")
		}
		set {
			setBool(newValue, forKey: "appendKanColleTag")
		}
	}
}

/// Preferences
extension HMUserDefaults {
	/// 遠征帰還時の通知音を鳴らす
	var playFinishMissionSound: Bool {
		get {
			return boolForKey("playFinishMissionSound")
		}
		set {
			setBool(newValue, forKey: "playFinishMissionSound")
		}
	}
	/// 入渠完了時の通知音を鳴らす
	var playFinishNyukyoSound: Bool {
		get {
			return boolForKey("playFinishNyukyoSound")
		}
		set {
			setBool(newValue, forKey: "playFinishNyukyoSound")
		}
	}
	/// 建造完了時の通知音を鳴らす
	var playFinishKenzoSound: Bool {
		get {
			return boolForKey("playFinishKenzoSound")
		}
		set {
			setBool(newValue, forKey: "playFinishKenzoSound")
		}
	}
}

/// Upgradable window
extension HMUserDefaults {
	/// Lv.1の艦娘を改造可能艦リストに表示するか
	var showLevelOneShipInUpgradableList: Bool {
		get {
			return boolForKey("showLevelOneShipInUpgradableList")
		}
		set {
			setBool(newValue, forKey: "showLevelOneShipInUpgradableList")
		}
	}
}

