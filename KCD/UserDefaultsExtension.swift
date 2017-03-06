//
//  UserDefaultsExtension.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/28.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa


extension UserDefaults {
    
    func keyedArchivedObject(forKey key: String) -> Any? {
        guard let data = object(forKey: key) as? Data else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: data)
    }
    func setKeyedArchived(_ object: Any?, forKey key: String) {
        guard let object = object else {
            removeObject(forKey: key)
            return
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        set(data, forKey: key)
    }
    
    class func registerAllDefaults() {
        let plan01Color = NSColor(calibratedRed: 0.000, green: 0.043, blue: 0.518, alpha: 1.0)
        let plan02Color = NSColor(calibratedRed: 0.800, green: 0.223, blue: 0.000, alpha: 1.0)
        let plan03Color = NSColor(calibratedRed: 0.539, green: 0.012, blue: 0.046, alpha: 1.0)
        let plan04Color = NSColor(calibratedRed: 0.000, green: 0.535, blue: 0.535, alpha: 1.0)
        let plan05Color = NSColor(calibratedRed: 0.376, green: 0.035, blue: 0.535, alpha: 1.0)
        let plan06Color = NSColor(calibratedRed: 0.535, green: 0.535, blue: 0.000, alpha: 1.0)
        
        standard.register(defaults:
            [
                "screenShotBorderWidth": 0.0,
                "plan01Color": NSKeyedArchiver.archivedData(withRootObject: plan01Color),
                "plan02Color": NSKeyedArchiver.archivedData(withRootObject: plan02Color),
                "plan03Color": NSKeyedArchiver.archivedData(withRootObject: plan03Color),
                "plan04Color": NSKeyedArchiver.archivedData(withRootObject: plan04Color),
                "plan05Color": NSKeyedArchiver.archivedData(withRootObject: plan05Color),
                "plan06Color": NSKeyedArchiver.archivedData(withRootObject: plan06Color),
                "screenshotPreviewZoomValue": 0.4,
                "showEquipmentType": -1,
                "fleetViewPosition": 1,
                "autoCombinedView": true,
                "screenshotEditorColumnCount": 2,
                "cleanSiceDays": 90,
                "notifyTimeSignal": false,
                "notifyTimeBeforeTimeSignal": 5,
                ]
        )
    }
}
extension UserDefaults {
    var slotItemSortDescriptors: [NSSortDescriptor] {
        get {
            return keyedArchivedObject(forKey: "slotItemSortKey2") as? [NSSortDescriptor] ?? []
        }
        set {
            setKeyedArchived(newValue, forKey: "slotItemSortKey2")
        }
    }
    var shipviewSortDescriptors: [NSSortDescriptor] {
        get {
            return keyedArchivedObject(forKey: "shipviewsortdescriptor") as? [NSSortDescriptor] ?? []
        }
        set {
            setKeyedArchived(newValue, forKey: "shipviewsortdescriptor")
        }
    }
    var powerupSupportSortDecriptors: [NSSortDescriptor] {
        get {
            return keyedArchivedObject(forKey: "powerupsupportsortdecriptor") as? [NSSortDescriptor] ?? []
        }
        set {
            setKeyedArchived(newValue, forKey: "powerupsupportsortdecriptor")
        }
    }
    
    // MARK: -
    var showsDebugMenu: Bool {
        get { return bool(forKey: "ShowsDebugMenu") }
        set { set(newValue, forKey: "ShowsDebugMenu") }
    }
    
    // MARK: -
    var appendKanColleTag: Bool {
        get { return bool(forKey: "appendKanColleTag") }
        set { set(newValue, forKey: "appendKanColleTag") }
    }
    
    // MARK: -
    var hideMaxKaryoku: Bool {
        get { return bool(forKey: "hideMaxKaryoku") }
        set { set(newValue, forKey: "hideMaxKaryoku") }
    }
    var hideMaxLucky: Bool {
        get { return bool(forKey: "hideMaxLucky") }
        set { set(newValue, forKey: "hideMaxLucky") }
    }
    var hideMaxRaisou: Bool {
        get { return bool(forKey: "hideMaxRaisou") }
        set { set(newValue, forKey: "hideMaxRaisou") }
    }
    var hideMaxSoukou: Bool {
        get { return bool(forKey: "hideMaxSoukou") }
        set { set(newValue, forKey: "hideMaxSoukou") }
    }
    var hideMaxTaiku: Bool {
        get { return bool(forKey: "hideMaxTaiku") }
        set { set(newValue, forKey: "hideMaxTaiku") }
    }
    
    // MARK: - plan color
    var showsPlanColor: Bool {
        get { return bool(forKey: "showsPlanColor") }
        set { set(newValue, forKey: "showsPlanColor") }
    }
    var plan01Color: NSColor {
        get { return keyedArchivedObject(forKey: "plan01Color") as! NSColor }
        set { setKeyedArchived(newValue, forKey: "plan01Color") }
    }
    var plan02Color: NSColor {
        get { return keyedArchivedObject(forKey: "plan02Color") as! NSColor }
        set { setKeyedArchived(newValue, forKey: "plan02Color") }
    }
    var plan03Color: NSColor {
        get { return keyedArchivedObject(forKey: "plan03Color") as! NSColor }
        set { setKeyedArchived(newValue, forKey: "plan03Color") }
    }
    var plan04Color: NSColor {
        get { return keyedArchivedObject(forKey: "plan04Color") as! NSColor }
        set { setKeyedArchived(newValue, forKey: "plan04Color") }
    }
    var plan05Color: NSColor {
        get { return keyedArchivedObject(forKey: "plan05Color") as! NSColor }
        set { setKeyedArchived(newValue, forKey: "plan05Color") }
    }
    var plan06Color: NSColor {
        get { return keyedArchivedObject(forKey: "plan06Color") as! NSColor }
        set { setKeyedArchived(newValue, forKey: "plan06Color") }
    }
    
    // MARK: -
    var minimumColoredShipCount: Int {
        get { return integer(forKey: "minimumColoredShipCount") }
        set { set(newValue, forKey: "minimumColoredShipCount") }
    }
    
    // MARK: - screenshot
    var useMask: Bool {
        get { return bool(forKey: "useMask") }
        set { set(newValue, forKey: "useMask") }
    }
    var screenShotBorderWidth: CGFloat {
        get {
            let r = double(forKey: "screenShotBorderWidth")
            if r < 0 { return 0.0 }
            else if r > 20 { return 20.0 }
            return CGFloat(r)
        }
        set {
            if 0.0..<20 ~= newValue { return }
            set(newValue, forKey: "screenShotBorderWidth")
        }
    }
    var screenShotSaveDirectory: String? {
        get { return object(forKey: "screenShotSaveDirectory") as? String }
        set { set(newValue, forKey: "screenShotSaveDirectory") }
    }
    var screenShotSaveDirectoryURL: URL? {
        guard let path = screenShotSaveDirectory else { return nil }
        return URL(fileURLWithPath: path, isDirectory: true)
    }
    var showsListWindowAtScreenshot: Bool {
        get { return bool(forKey: "showsListWindowAtScreenshot") }
        set { set(newValue, forKey: "showsListWindowAtScreenshot") }
    }
    var screenshotPreviewZoomValue: Double {
        get { return double(forKey: "screenshotPreviewZoomValue") }
        set { set(newValue, forKey: "screenshotPreviewZoomValue") }
    }
    var screenshotEditorColumnCount: Int {
        get { return integer(forKey: "screenshotEditorColumnCount") }
        set { set(newValue, forKey: "screenshotEditorColumnCount") }
    }
    var scrennshotEditorType: Int {
        get { return integer(forKey: "scrennshotEditorType") }
        set { set(newValue, forKey: "scrennshotEditorType") }
    }
    var screenshotButtonSize: NSControlSize {
        get {
            return NSControlSize(rawValue: UInt(integer(forKey: "screenshotButtonSize"))) ?? .regular
        
        }
        set { set(newValue.rawValue, forKey: "screenshotButtonSize") }
    }
    
    // MARK: - Notify Sound
    var playFinishMissionSound: Bool {
        get { return bool(forKey: "playFinishMissionSound") }
        set { set(newValue, forKey: "playFinishMissionSound") }
    }
    var playFinishNyukyoSound: Bool {
        get { return bool(forKey: "playFinishNyukyoSound") }
        set { set(newValue, forKey: "playFinishNyukyoSound") }
    }
    var playFinishKenzoSound: Bool {
        get { return bool(forKey: "playFinishKenzoSound") }
        set { set(newValue, forKey: "playFinishKenzoSound") }
    }
    
    // MARK: - Upgradable List
    var showLevelOneShipInUpgradableList: Bool {
        get { return bool(forKey: "showLevelOneShipInUpgradableList") }
        set { set(newValue, forKey: "showLevelOneShipInUpgradableList") }
    }
    var showsExcludedShipInUpgradableList: Bool {
        get { return bool(forKey: "showsExcludedShipInUpgradableList") }
        set { set(newValue, forKey: "showsExcludedShipInUpgradableList") }
    }
    
    // MARK: - Equipment List
    var showEquipmentType: SlotItemWindowController.ShowType {
        get {
            let t = integer(forKey: "showEquipmentType")
            let type = SlotItemWindowController.ShowType(rawValue: t)
            return type ?? .all
        }
        set { set(newValue.rawValue, forKey: "showEquipmentType") }
    }
    
    // MARK: - FleetView
    var fleetViewPosition: BroserWindowController.FleetViewPosition {
        get {
            let t = integer(forKey: "fleetViewPosition")
            let position = BroserWindowController.FleetViewPosition(rawValue: t)
            return position ?? .above
        }
        set { set(newValue.rawValue, forKey: "fleetViewPosition") }
    }
    var fleetViewShipOrder: FleetViewController.ShipOrder {
        get {
            let o = integer(forKey: "fleetViewShipOrder")
            let order = FleetViewController.ShipOrder(rawValue: o)
            return order ?? .doubleLine
        }
        set { set(newValue.rawValue, forKey: "fleetViewShipOrder") }
    }
    var repairTime: Date {
        get { return keyedArchivedObject(forKey: "repairTime") as? Date ?? Date() }
        set { setKeyedArchived(newValue, forKey: "repairTime") }
    }
    
    // MARK: - combined view
    var lastHasCombinedView: Bool {
        get { return bool(forKey: "lastHasCombinedView") }
        set { set(newValue, forKey: "lastHasCombinedView") }
    }
    var autoCombinedView: Bool {
        get { return bool(forKey: "autoCombinedView") }
        set { set(newValue, forKey: "autoCombinedView") }
    }
    var useSwipeChangeCombinedView: Bool {
        get { return bool(forKey: "useSwipeChangeCombinedView") }
        set { set(newValue, forKey: "useSwipeChangeCombinedView") }
    }
    
    // MARK: - Old History Item Clean
    var cleanOldHistoryItems: Bool {
        get { return bool(forKey: "cleanOldHistoryItems") }
        set { set(newValue, forKey: "cleanOldHistoryItems") }
    }
    var cleanSiceDays: Int {
        get { return integer(forKey: "cleanSiceDays") }
        set { set(newValue, forKey: "cleanSiceDays") }
    }
    
    // MARK: - Notify time signal
    var notifyTimeSignal: Int {
        get { return integer(forKey: "notifyTimeSignal") }
        set { set(newValue, forKey: "notifyTimeSignal") }
    }
    var notifyTimeBeforeTimeSignal: Int {
        get { return integer(forKey: "notifyTimeBeforeTimeSignal") }
        set {
            if newValue < 1 { set(1, forKey: "notifyTimeBeforeTimeSignal") }
            else if newValue > 59 { set(59, forKey: "notifyTimeBeforeTimeSignal") }
            else { set(newValue, forKey: "notifyTimeBeforeTimeSignal") }
        }
    }
    var playNotifyTimeSignalSound: Bool {
        get { return bool(forKey: "playNotifyTimeSignalSound") }
        set { set(newValue, forKey: "playNotifyTimeSignalSound") }
    }
    
    // MARK: - Debug print
    var degugPrintLevel: Debug.Level {
        return Debug.Level(rawValue: integer(forKey: "DebugPrintLevel")) ?? .none
    }
}

extension UserDefaults {
    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss' 'Z"
        return f
    }
    var prevReloadDate: Date? {
        get {
            guard let p = object(forKey: "previousReloadDateString") as? String else { return nil }
            return dateFormatter.date(from: p)
        }
        set {
            guard let newValue = newValue else {
                removeObject(forKey: "previousReloadDateString")
                return
            }
            let data = dateFormatter.string(from: newValue)
            set(data, forKey: "previousReloadDateString")
        }
    }
}
