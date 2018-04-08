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
    @NSManaged dynamic var soku: Int
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

private let shortSTypeNames: [String] = {
    
    guard let url = Bundle.main.url(forResource: "STypeShortName", withExtension: "plist"),
        let array = NSArray(contentsOf: url) as? [String] else {
            
            Logger.shared.log("Can not load STypeShortName.plist.")
            
            return []
    }
    
    return array
}()

private let levelUpExps: [Int] = {
    
    guard let url = Bundle.main.url(forResource: "LevelUpExp", withExtension: "plist"),
        let array = NSArray(contentsOf: url) as? [Int] else {
            
            Logger.shared.log("Can not load LevelUpExp.plist.")
            
            return []
    }
    
    return array
}()

extension Ship {
    
    @objc override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        
        switch key {
            
        case #keyPath(name): return [#keyPath(ship_id)]
            
        case #keyPath(shortTypeName): return [#keyPath(ship_id)]
            
        case #keyPath(next): return [#keyPath(exp)]
            
        case #keyPath(status): return [#keyPath(nowhp), #keyPath(maxhp)]
        
        case #keyPath(planColor): return [#keyPath(sally_area)]
            
        case #keyPath(isMaxKaryoku): return [#keyPath(karyoku_1), #keyPath(kyouka_0)]
            
        case #keyPath(isMaxRaisou): return [#keyPath(raisou_1), #keyPath(kyouka_1)]
            
        case #keyPath(isMaxTaiku): return [#keyPath(taiku_1), #keyPath(kyouka_2)]
            
        case #keyPath(isMaxSoukou): return [#keyPath(soukou_1), #keyPath(kyouka_3)]
            
        case #keyPath(isMaxLucky): return [#keyPath(lucky_1), #keyPath(kyouka_4)]
            
        case #keyPath(upgradeLevel): return [#keyPath(ship_id)]
            
        case #keyPath(upgradeExp): return [#keyPath(exp)]
            
        case #keyPath(steelRequiredInRepair): return [#keyPath(nowhp)]
            
        case #keyPath(fuelRequiredInRepair): return [#keyPath(nowhp)]
            
        case #keyPath(seiku): return [#keyPath(slot_0), #keyPath(slot_1), #keyPath(slot_2), #keyPath(slot_3), #keyPath(slot_4),
                                      #keyPath(onslot_0), #keyPath(onslot_1), #keyPath(onslot_2), #keyPath(onslot_3), #keyPath(onslot_4)]
            
        default: return []
            
        }
    }
    
    @objc dynamic var name: String { return master_ship.name }
    
    @objc dynamic var shortTypeName: String? {
        
        let index = master_ship.stype.id - 1
        
        guard case 0..<shortSTypeNames.count = index else {
            
            return nil
        }
        
        return shortSTypeNames[index]
    }
    
    @objc dynamic var next: NSNumber? {
        
        guard case 0..<levelUpExps.count = lv else {
            
            return nil
        }
        
        if lv == 99 {
            
            return nil
        }
        
        let nextExp = levelUpExps[lv]
        
        if lv < 99 {
            
            return (nextExp - exp) as NSNumber
        }
        
        return (1_000_000 + nextExp - exp) as NSNumber
    }
    
    @objc dynamic var status: Int {
        
        switch Double(nowhp) / Double(maxhp) {
            
        case (0...0.25): return 3
            
        case (0.25...0.50): return 2
            
        case (0.50...0.75): return 1
            
        default: return 0
            
        }
    }
    
    @objc dynamic var planColor: NSColor {
        
        if !UserDefaults.standard[.showsPlanColor] {
            
            return .controlTextColor
        }
        
        guard let sally = sally_area else {
            
            return .controlTextColor
        }
        
        switch sally {
            
        case 1: return UserDefaults.standard[.plan01Color]
            
        case 2: return UserDefaults.standard[.plan02Color]
            
        case 3: return UserDefaults.standard[.plan03Color]
            
        case 4: return UserDefaults.standard[.plan04Color]
            
        case 5: return UserDefaults.standard[.plan05Color]
            
        case 6: return UserDefaults.standard[.plan06Color]
            
        default: return .controlTextColor
            
        }
    }
}


extension Ship {
    
    @objc dynamic var maxBull: Int { return master_ship.bull_max }
    @objc dynamic var maxFuel: Int { return master_ship.fuel_max }
    
    @objc dynamic var isMaxKaryoku: Bool {
        
        let initial = master_ship.houg_0
        let max = karyoku_1
        let growth = kyouka_0
        
        return initial + growth >= max
    }
    
    @objc dynamic var isMaxRaisou: Bool {
        
        let initial = master_ship.raig_0
        let max = raisou_1
        let growth = kyouka_1
        
        return initial + growth >= max
    }
    
    @objc dynamic var isMaxTaiku: Bool {
        
        let initial = master_ship.tyku_0
        let max = taiku_1
        let growth = kyouka_2
        
        return initial + growth >= max
    }
    
    @objc dynamic var isMaxSoukou: Bool {
        
        let initial = master_ship.souk_0
        let max = soukou_1
        let growth = kyouka_3
        
        return initial + growth >= max
    }
    
    @objc dynamic var isMaxLucky: Bool {
        
        let initial = master_ship.luck_0
        let max = lucky_1
        let growth = kyouka_4
        
        return initial + growth >= max
    }
    
    @objc dynamic var upgradeLevel: Int { return master_ship.afterlv }
    
    @objc dynamic var upgradeExp: NSNumber? {
        
        let upgradeLv = upgradeLevel
        
        if upgradeLv <= 0 {
            
            return nil
        }
        if levelUpExps.count < upgradeLv {
            
            return nil
        }
        
        let upExp = levelUpExps[upgradeLv - 1] - exp
        
        return upExp < 0 ? 0 : upExp as NSNumber
    }
    
    @objc dynamic var guardEscaped: Bool {
        
        let store = TemporaryDataStore.default
        
        guard let _ = store.ensuredGuardEscaped(byShipId: id) else {
            
            return false
        }
        
        return true
    }
    
    @objc dynamic var steelRequiredInRepair: Int {
        
        return Int(Double(maxFuel) * 0.06 * Double(maxhp - nowhp))
    }
    
    @objc dynamic var fuelRequiredInRepair: Int {
        
        return Int(Double(maxFuel) * 0.032 * Double(maxhp - nowhp))
    }
}

extension Ship {
    
    func setItem(_ id: Int, to slot: Int) {
        
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
    
    func slotItemMax(_ index: Int) -> Int {
        
        switch index {
            
        case 0: return master_ship.maxeq_0
            
        case 1: return master_ship.maxeq_1
            
        case 2: return master_ship.maxeq_2
            
        case 3: return master_ship.maxeq_3
            
        case 4: return master_ship.maxeq_4
            
        default: return 0
            
        }
    }
    
    func slotItem(_ index: Int) -> SlotItem? {
        
        return ServerDataStore.default.slotItem(by: slotItemId(index))
    }
    
    @objc dynamic var totalEquipment: Int {
        
        return (0...4).map(slotItemMax).reduce(0, +)
    }
    
    @objc dynamic var seiku: Int {
        
        return SeikuCalclator(ship: self).seiku
    }
    
}
