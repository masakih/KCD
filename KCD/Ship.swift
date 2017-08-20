//
//  [
//  KCD
//
//  Created by Hori,Masaki on 2017/01/29.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

// swiftlint:disable variable_name
final class Ship: KCManagedObject {
    
    @NSManaged dynamic var bull: Int
    @NSManaged dynamic var cond: Int
    @NSManaged dynamic var exp: Int
    @NSManaged dynamic var fleet: NSNumber?
    @NSManaged dynamic var fuel: Int
    @NSManaged dynamic var id: Int
    @NSManaged dynamic var kaihi_0: Int
    @NSManaged dynamic var kaihi_1: NSNumber?
    @NSManaged dynamic var karyoku_0: Int
    @NSManaged dynamic var karyoku_1: Int
    @NSManaged dynamic var kyouka_0: Int
    @NSManaged dynamic var kyouka_1: Int
    @NSManaged dynamic var kyouka_2: Int
    @NSManaged dynamic var kyouka_3: Int
    @NSManaged dynamic var kyouka_4: Int
    @NSManaged dynamic var locked: Int
    @NSManaged dynamic var locked_equip: NSNumber?
    @NSManaged dynamic var lucky_0: Int
    @NSManaged dynamic var lucky_1: Int
    @NSManaged dynamic var lv: Int
    @NSManaged dynamic var maxhp: Int
    @NSManaged dynamic var ndock_time: NSNumber?
    @NSManaged dynamic var nowhp: Int
    @NSManaged dynamic var onslot_0: Int
    @NSManaged dynamic var onslot_1: Int
    @NSManaged dynamic var onslot_2: Int
    @NSManaged dynamic var onslot_3: Int
    @NSManaged dynamic var onslot_4: Int
    @NSManaged dynamic var raisou_0: Int
    @NSManaged dynamic var raisou_1: Int
    @NSManaged dynamic var sakuteki_0: Int
    @NSManaged dynamic var sakuteki_1: NSNumber?
    @NSManaged dynamic var sally_area: NSNumber?
    @NSManaged dynamic var ship_id: Int
    @NSManaged dynamic var slot_0: Int
    @NSManaged dynamic var slot_1: Int
    @NSManaged dynamic var slot_2: Int
    @NSManaged dynamic var slot_3: Int
    @NSManaged dynamic var slot_4: Int
    @NSManaged dynamic var slot_ex: Int
    @NSManaged dynamic var sortno: NSNumber?
    @NSManaged dynamic var soukou_0: Int
    @NSManaged dynamic var soukou_1: Int
    @NSManaged dynamic var srate: NSNumber?
    @NSManaged dynamic var taiku_0: Int
    @NSManaged dynamic var taiku_1: Int
    @NSManaged dynamic var taisen_0: Int
    @NSManaged dynamic var taisen_1: NSNumber?
    @NSManaged dynamic var equippedItem: NSOrderedSet
    @NSManaged dynamic var master_ship: MasterShip
    @NSManaged dynamic var extraItem: SlotItem?
}
// swiftlint:eable variable_name

fileprivate let shortSTypeNames: [String] = {
    
    guard let url = Bundle.main.url(forResource: "STypeShortName", withExtension: "plist"),
        let array = NSArray(contentsOf: url) as? [String]
        else {
            print("Can not load STypeShortName.plist.")
            return []
    }
    
    return array
}()

fileprivate let levelUpExps: [Int] = {
    
    guard let url = Bundle.main.url(forResource: "LevelUpExp", withExtension: "plist"),
        let array = NSArray(contentsOf: url) as? [Int]
        else {
            print("Can not load LevelUpExp.plist.")
            return []
    }
    
    return array
}()

extension Ship {
    
    class func keyPathsForValuesAffectingName() -> Set<String> {
        
        return ["ship_id"]
    }
    dynamic var name: String { return master_ship.name }
    
    class func keyPathsForValuesAffectingShortTypeName() -> Set<String> {
        
        return ["ship_id"]
    }
    dynamic var shortTypeName: String? {
        
        let index = master_ship.stype.id - 1
        
        guard case 0..<shortSTypeNames.count = index
            else { return nil }
        
        return shortSTypeNames[index]
    }
    
    class func keyPathsForValuesAffectingNext() -> Set<String> {
        
        return ["exp"]
    }
    dynamic var next: NSNumber? {
        
        guard case 0..<levelUpExps.count = lv
            else { return nil }
        
        if lv == 99 { return nil }
        
        let nextExp = levelUpExps[lv]
        
        if lv < 99 { return (nextExp - exp) as NSNumber }
        
        return (1_000_000 + nextExp - exp) as NSNumber
    }
    
    class func keyPathsForValuesAffectingStatus() -> Set<String> {
        
        return ["nowhp", "maxph"]
    }
    dynamic var status: Int {
        
        let stat = Double(nowhp) / Double(maxhp)
        
        if stat <= 0.25 { return 3 }
        if stat <= 0.5 { return 2 }
        if stat <= 0.75 { return 1 }
        
        return 0
    }
    
    class func keyPathsForValuesAffectingStatusColor() -> Set<String> {
        
        return ["status"]
    }
    dynamic var statusColor: NSColor {
        
        switch status {
        case 0: return NSColor.controlTextColor
        case 1: return NSColor.yellow
        case 2: return NSColor.orange
        case 3: return NSColor.red
        default: fatalError("status is unknown value")
        }
    }
    
//    class func keyPathsForValuesAffectingConditionColor() -> Set<String> {
//        return ["cond"]
//    }
    dynamic var conditionColor: NSColor { return NSColor.controlTextColor }
    
    class func keyPathsForValuesAffectingPlanColor() -> Set<String> {
        
        return ["sally_area"]
    }
    dynamic var planColor: NSColor {
        
        if !UserDefaults.standard[.showsPlanColor] { return NSColor.controlTextColor }
        
        guard let sally = sally_area
            else { return NSColor.controlTextColor }
        
        switch sally {
        case 1: return UserDefaults.standard[.plan01Color]
        case 2: return UserDefaults.standard[.plan02Color]
        case 3: return UserDefaults.standard[.plan03Color]
        case 4: return UserDefaults.standard[.plan04Color]
        case 5: return UserDefaults.standard[.plan05Color]
        case 6: return UserDefaults.standard[.plan06Color]
        default: return NSColor.controlTextColor
        }
    }
}


extension Ship {
    
    dynamic var maxBull: Int { return master_ship.bull_max }
    dynamic var maxFuel: Int { return master_ship.fuel_max }
    
    class func keyPathsForValuesAffectingIsMaxKaryoku() -> Set<String> {
        
        return ["karyoku_1", "kyouka_0"]
    }
    dynamic var isMaxKaryoku: Bool {
        
        let initial = master_ship.houg_0
        let max = karyoku_1
        let growth = kyouka_0
        
        return initial + growth >= max
    }
    
    class func keyPathsForValuesAffectingIsMaxRaisou() -> Set<String> {
        
        return ["raisou_1", "kyouka_1"]
    }
    dynamic var isMaxRaisou: Bool {
        
        let initial = master_ship.raig_0
        let max = raisou_1
        let growth = kyouka_1
        
        return initial + growth >= max
    }
    
    class func keyPathsForValuesAffectingIsMaxTaiku() -> Set<String> {
        
        return ["taiku_1", "kyouka_2"]
    }
    dynamic var isMaxTaiku: Bool {
        
        let initial = master_ship.tyku_0
        let max = taiku_1
        let growth = kyouka_2
        
        return initial + growth >= max
    }
    
    class func keyPathsForValuesAffectingIsMaxSoukou() -> Set<String> {
        
        return ["soukou_1", "kyouka_3"]
    }
    dynamic var isMaxSoukou: Bool {
        
        let initial = master_ship.souk_0
        let max = soukou_1
        let growth = kyouka_3
        
        return initial + growth >= max
    }
    
    class func keyPathsForValuesAffectingIsMaxLucky() -> Set<String> {
        
        return ["lucky_1", "kyouka_4"]
    }
    dynamic var isMaxLucky: Bool {
        
        let initial = master_ship.luck_0
        let max = lucky_1
        let growth = kyouka_4
        
        return initial + growth >= max
    }
    
    class func keyPathsForValuesAffectingUpgradeLevel() -> Set<String> {
        
        return ["ship_id"]
    }
    dynamic var upgradeLevel: Int { return master_ship.afterlv }
    
    class func keyPathsForValuesAffectingUpgradeExp() -> Set<String> {
        
        return ["exp"]
    }
    dynamic var upgradeExp: NSNumber? {
        
        let upgradeLv = upgradeLevel
        
        if upgradeLv <= 0 { return nil }
        if levelUpExps.count < upgradeLv { return nil }
        
        let upExp = levelUpExps[upgradeLv - 1] - exp
        
        return upExp < 0 ? 0 : upExp as NSNumber
    }
    
    dynamic var guardEscaped: Bool {
        
        let store = TemporaryDataStore.default
        
        guard let _ = store.ensuredGuardEscaped(byShipId: id)
            else { return false }
        
        return true
    }
    
    class func keyPathsForValuesAffectingSteelRequiredInRepair() -> Set<String> {
        
        return ["nowhp"]
    }
    dynamic var steelRequiredInRepair: Int {
        
        return Int(Double(maxFuel) * 0.06 * Double(maxhp - nowhp))
    }
    
    class func keyPathsForValuesAffectingFuelRequiredInRepair() -> Set<String> {
        
        return ["nowhp"]
    }
    dynamic var fuelRequiredInRepair: Int {
        
        return Int(Double(maxFuel) * 0.032 * Double(maxhp - nowhp))
    }
}

fileprivate let allPlaneTypes: [Int] = [6, 7, 8, 9, 10, 11, 25, 26, 41, 45, 56, 57, 58, 59]

extension Ship {
    
    func setItem(_ id: Int, for slot: Int) {
        
        switch slot {
        case 0: slot_0 = id
        case 1: slot_1 = id
        case 2: slot_2 = id
        case 3: slot_3 = id
        case 4: slot_4 = id
        default: fatalError("Ship: setItem out of bounds.")
        }
    }
    
    func slotItemId(_ index: Int) -> Int {
        
        switch index {
        case 0: return slot_0
        case 1: return slot_1
        case 2: return slot_2
        case 3: return slot_3
        case 4: return slot_4
        default: return 0
        }
    }
    
    func slotItemCount(_ index: Int) -> Int {
        
        switch index {
        case 0: return onslot_0
        case 1: return onslot_1
        case 2: return onslot_2
        case 3: return onslot_3
        case 4: return onslot_4
        default: return 0
        }
    }
    
    private func slotItemMax(_ index: Int) -> Int {
        
        switch index {
        case 0: return master_ship.maxeq_0
        case 1: return master_ship.maxeq_1
        case 2: return master_ship.maxeq_2
        case 3: return master_ship.maxeq_3
        case 4: return master_ship.maxeq_4
        default: return 0
        }
    }
    
    private func slotItem(_ index: Int) -> SlotItem? {
        
        return ServerDataStore.default.slotItem(by: slotItemId(index))
    }
    
    dynamic var totalEquipment: Int {
        
        return (0...4).map(slotItemMax).reduce(0, +)
    }
    
    class func keyPathsForValuesAffectingSeiku() -> Set<String> {
        
        return ["slot_0", "slot_1", "slot_2", "slot_3", "slot_4",
                   "onslot_0", "onslot_1", "onslot_2", "onslot_3", "onslot_4"]
    }
    dynamic var seiku: Int {
        
        return SeikuCalclator(ship: self).seiku
    }
    
    class func keyPathsForValuesAffectingTotalSeiku() -> Set<String> {
        
        return ["seiku"]
    }
    var totalSeiku: Int {
        
        return SeikuCalclator(ship: self).totalSeiku
    }
    
    var totalDrums: Int {
        
        return (0...4).flatMap(slotItem).filter { $0.slotitem_id == 75 }.count
    }
    
    // MARK: - Plane count strings
    private enum PlaneState {
        
        case cannotEquip
        case notEquip(Int)
        case equiped(Int, Int)
    }
    
    private func planState(_ index: Int) -> PlaneState {
        
        let itemId = slotItemId(index)
        let maxCount = slotItemMax(index)
        
        if maxCount == 0 { return .cannotEquip }
        if itemId == -1 { return .notEquip(maxCount) }
        
        if let item = slotItem(index),
            allPlaneTypes.contains(item.master_slotItem.type_2) {
            
            return .equiped(slotItemCount(index), maxCount)
        }
        
        return .notEquip(maxCount)
    }
    
    private func planeString(_ index: Int) -> String? {
        
        switch planState(index) {
        case .cannotEquip:
            return nil
        case .notEquip(let max):
            return "\(max)"
        case .equiped(let count, let max):
            return "\(count)/\(max)"
        }
    }
    
    class func keyPathsForValuesAffectingPlaneString0() -> Set<String> {
        
        return ["onslot_0", "master_ship.maxeq_0", "equippedItem"]
    }
    dynamic var planeString0: String? { return planeString(0) }
    
    class func keyPathsForValuesAffectingPlaneString1() -> Set<String> {
        
        return ["onslot_1", "master_ship.maxeq_1", "equippedItem"]
    }
    dynamic var planeString1: String? { return planeString(1) }
    
    class func keyPathsForValuesAffectingPlaneString2() -> Set<String> {
        
        return ["onslot_2", "master_ship.maxeq_2", "equippedItem"]
    }
    dynamic var planeString2: String? { return planeString(2) }
    
    class func keyPathsForValuesAffectingPlaneString3() -> Set<String> {
        
        return ["onslot_3", "master_ship.maxeq_3", "equippedItem"]
    }
    dynamic var planeString3: String? { return planeString(3) }
    
    class func keyPathsForValuesAffectingPlaneString4() -> Set<String> {
        
        return ["onslot_4", "master_ship.maxeq_4", "equippedItem"]
    }
    dynamic var planeString4: String? { return planeString(4) }
    
    // MARK: - Plane count string color
    private func planeStringColor(_ index: Int) -> NSColor {
        switch planState(index) {
        case .cannotEquip: return NSColor.controlTextColor
        case .notEquip: return NSColor.disabledControlTextColor
        case .equiped: return NSColor.controlTextColor
        }
    }
    
    class func keyPathsForValuesAffectingPlaneString0Color() -> Set<String> {
        
        return ["onslot_0", "master_ship.maxeq_0", "equippedItem"]
    }
    dynamic var planeString0Color: NSColor { return planeStringColor(0) }
    
    class func keyPathsForValuesAffectingPlaneString1Color() -> Set<String> {
        
        return ["onslot_1", "master_ship.maxeq_1", "equippedItem"]
    }
    dynamic var planeString1Color: NSColor { return planeStringColor(1) }
    
    class func keyPathsForValuesAffectingPlaneString2Color() -> Set<String> {
        
        return ["onslot_2", "master_ship.maxeq_2", "equippedItem"]
    }
    dynamic var planeString2Color: NSColor { return planeStringColor(2) }
    
    class func keyPathsForValuesAffectingPlaneString3Color() -> Set<String> {
        
        return ["onslot_3", "master_ship.maxeq_3", "equippedItem"]
    }
    dynamic var planeString3Color: NSColor { return planeStringColor(3) }
    
    class func keyPathsForValuesAffectingPlaneString4Color() -> Set<String> {
        
        return ["onslot_4", "master_ship.maxeq_4", "equippedItem"]
    }
    dynamic var planeString4Color: NSColor { return planeStringColor(4) }
}
