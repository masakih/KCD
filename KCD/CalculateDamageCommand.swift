//
//  CalculateDamageCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/15.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate enum BattleType {
    case normal
    case combinedAir
    case combinedWater
    case eachCombinedAir
    case eachCombinedWater
    case enemyCombined
}
fileprivate enum DamageControlID: Int {
    case damageControl = 42
    case goddes = 43
}
fileprivate enum BattleFleet {
    case first
    case second
    case each
}

class CalculateDamageCommand: JSONCommand {
    private let store = TemporaryDataStore.oneTimeEditor()
    
    fileprivate var battleType: BattleType = .normal
    fileprivate var damages: [Damage] {
        let array = store.sortedDamagesById()
        if array.count != 12 {
            buildDamagedEntity()
            let newDamages = store.sortedDamagesById()
            guard newDamages.count == 12
                else {
                    print("ERROR!!!! CAN NOT CREATE DAMAGE OBJECT")
                    return []
            }
            return newDamages
        }
        return array
    }
    fileprivate var isCombinedBattle: Bool {
        switch battleType {
        case .combinedAir, .combinedWater, .eachCombinedAir, .eachCombinedWater:
            return true
        default:
            return false
        }
    }
    
    override func execute() {
        guard let battleApi = BattleAPI(rawValue: api)
            else { return }
        
        switch battleApi {
        case .battle, .airBattle, .ldAirBattle:
            calculateBattle()
        case .combinedEcBattle:
            battleType = .enemyCombined
            calcEnemyCombinedBattle()
        case .combinedBattle, .combinedAirBattle:
            battleType = .combinedAir
            calcCombinedBattleAir()
        case .combinedBattleWater, .combinedLdAirBattle:
            battleType = .combinedWater
            calculateBattle()
        case .combinedEachBattle:
            battleType = .eachCombinedAir
            calcEachBattleAir()
        case .combinedEachBattleWater:
            battleType = .eachCombinedWater
            calculateBattle()
        case .midnightBattle, .midnightSpMidnight, .combinedMidnightBattle, .combinedSpMidnight:
            calculateMidnightBattle()
        case .combinedEcMidnightBattle:
            battleType = .eachCombinedAir
            calculateMidnightBattle()
        case .battleResult, .combinedBattleResult:
            applyDamage()
            resetDamage()
        }
    }
    
    private func resetDamage() {
        store.damages().forEach { store.delete($0) }
    }
    private func applyDamage() {
        let totalDamages = store.sortedDamagesById()
        guard totalDamages.count == 12
            else { return print("Damages count is invalid") }
        let aStore = ServerDataStore.oneTimeEditor()
        totalDamages.forEach {
            guard let ship = aStore.ship(byId: $0.shipID)
                else { return }
            
            if ship.nowhp != $0.hp {
                Debug.print("\(ship.name)(\(ship.id)),HP \(ship.nowhp) -> \($0.hp)", level: .debug)
            }
            
            ship.nowhp = $0.hp
            if $0.useDamageControl { removeFirstDamageControl(of: ship) }
        }
    }
    private func buildDamagedEntity() {
        guard let battle = store.battle()
            else { return print("Battle is invalid.") }
        
        let aStore = ServerDataStore.default
        var ships: [Any] = []
        
        // 第一艦隊
        let firstFleetShips = aStore.ships(byDeckId: battle.deckId)
        ships += (firstFleetShips as [Any])
        while ships.count != 6 {
            ships.append(0)
        }
        
        // 第二艦隊
        let secondFleetShips = aStore.ships(byDeckId: 2)
        ships += (secondFleetShips as [Any])
        while ships.count != 12 {
            ships.append(0)
        }
        ships.enumerated().forEach {
            guard let damage = store.createDamage()
                else { return print("Can not create Damage") }
            damage.battle = battle
            damage.id = $0.offset
            if let ship = $0.element as? Ship {
                damage.hp = ship.nowhp
                damage.shipID = ship.id
            }
        }
    }
    
    fileprivate func updateBattleCell() {
        guard let battle = store.battle()
            else { return print("Battle is invalid.") }
        battle.battleCell = (battle.no == 0 ? nil : battle.no as NSNumber)
    }
}
// MARK: - Primitive Calclator
extension CalculateDamageCommand {
    private func isTargetFriend(eFlags: [Int]?, index: Int) -> Bool {
        if let eFlags = eFlags, 0..<eFlags.count ~= index {
            return eFlags[index] == 1
        }
        return true
    }
    fileprivate func calculateHogeki(baseKeyPath: String, _ bf: () -> BattleFleet) {
        calculateHogeki(baseKeyPath: baseKeyPath, battleFleet: bf())
    }
    fileprivate func calculateHogeki(baseKeyPath: String, battleFleet: BattleFleet = .first) {
        let j = json as NSDictionary
        guard let data = j.value(forKeyPath: baseKeyPath) as? [String: Any],
            let dfList = data["api_df_list"] as? [Any],
            let damageList = data["api_damage"] as? [Any]
            else { return }
        guard let targetArraysArray = dfList.filter({ $0 is [Int] }) as? [[Int]],
            dfList.count - 1 == targetArraysArray.count
            else { return print("api_df_list is wrong") }
        guard let hougeki1Damages = damageList.filter({ $0 is [Int] }) as? [[Int]],
            targetArraysArray.count == hougeki1Damages.count
            else { return print("api_damage is wrong") }
        let eFlags: [Int]? = (data["api_at_eflag"] as? [Int])?.filter { $0 != -1 }
        
        Debug.print("Start Hougeki \(baseKeyPath)", level: .debug)
        let shipOffset = (battleFleet == .second) ? 6 : 0
        targetArraysArray.enumerated().forEach { (i, targetArray) in
            targetArray.enumerated().forEach { (j, targetPosition) in
                if !isTargetFriend(eFlags: eFlags, index: i) { return }
                
                if battleFleet == .each {
                    guard 1...12 ~= targetPosition else { return }
                } else {
                    guard 1...6 ~= targetPosition else { return }
                }
                
                let damagePos = targetPosition - 1 + shipOffset
                guard 0..<damages.count ~= damagePos
                    else { return print("damage pos is larger than damage count") }
                let damageObject = damages[damagePos]
                guard 0..<hougeki1Damages[i].count ~= j
                    else { return print("target pos is larger than damages") }
                let damage = hougeki1Damages[i][j]
                let hp = damageObject.hp
                var newHP = (hp as Int) - damage
                if newHP <= 0 {
                    let shipId = damageObject.shipID
                    if let ship = ServerDataStore.default.ship(byId: shipId) {
                        let efectiveHP = damageControlIfPossible(nowhp: newHP, ship: ship)
                        if efectiveHP != 0, efectiveHP != newHP {
                            damageObject.useDamageControl = true
                        }
                        newHP = efectiveHP
                    }
                }
                damageObject.hp = newHP
                
                Debug.print("Hougeki \(targetPosition + shipOffset) -> \(damage)", level: .debug)
            }
        }
    }
    fileprivate func calculateFDam(baseKeyPath: String, _ bf: () -> BattleFleet) {
        calculateFDam(baseKeyPath: baseKeyPath, battleFleet: bf())
    }
    fileprivate func calculateFDam(baseKeyPath: String, battleFleet: BattleFleet = .first) {
        let j = json as NSDictionary
        guard let data = j.value(forKeyPath: baseKeyPath) as? [String: Any],
            let koukuDamages = data["api_fdam"] as? [Int]
            else { return }
        
        Debug.print("Start FDam \(baseKeyPath)", level: .debug)
        
        let shipOffset = (battleFleet == .second) ? 6 : 0
        koukuDamages.enumerated().forEach { (idx, damage) in
            if idx == 0 { return }
            
            let damagePos = idx - 1 + shipOffset
            guard 0..<damages.count ~= damagePos
                else { return }
            let damageObject = damages[damagePos]
            var newHP = damageObject.hp - damage
            if newHP <= 0 {
                let shipId = damageObject.shipID
                if let ship = ServerDataStore.default.ship(byId: shipId) {
                    let efectiveHP = damageControlIfPossible(nowhp: newHP, ship: ship)
                    if efectiveHP != 0 && efectiveHP != newHP {
                        damageObject.useDamageControl = true
                    }
                    newHP = efectiveHP
                }
                damageObject.hp = newHP
            }
            damageObject.hp = newHP
            
            Debug.print("FDam \(idx + shipOffset) -> \(damage)", level: .debug)
        }
    }
}
// MARK: - Battle phase
extension CalculateDamageCommand {
    fileprivate func calcKouku() {
        calculateFDam(baseKeyPath: "api_data.api_kouku.api_stage3")
        calculateFDam(baseKeyPath: "api_data.api_kouku2.api_stage3")
        
        // 艦隊　戦闘艦隊
        // 連合vs通常（水上）　第２
        // 連合vs通常（機動）　第２
        // 連合vs連合（水上）　第２　全体 use kouku nor kouku2
        // 連合vs連合（機動）　第１　全体 use kouku nor kouku2
        let bf: () -> BattleFleet = {
            switch self.battleType {
            case .combinedWater, .combinedAir,
                 .eachCombinedWater, .eachCombinedAir:
                return .second
            default: return .first
            }
        }
        calculateFDam(baseKeyPath: "api_data.api_kouku.api_stage3_combined", bf)
        calculateFDam(baseKeyPath: "api_data.api_kouku2.api_stage3_combined", bf)
        
    }
    fileprivate func calcOpeningAttack() {
        // 艦隊　戦闘艦隊
        // 連合vs通常（水上）　第２
        // 連合vs通常（機動）　第２
        // 連合vs連合（水上）　第２　全体
        // 連合vs連合（機動）　第２　全体
        calculateFDam(baseKeyPath: "api_data.api_opening_atack") {
            switch battleType {
            case .combinedWater, .combinedAir: return .second
            case .eachCombinedWater, .eachCombinedAir: return .each
            default: return .first
            }
        }
    }
    fileprivate func calcOpeningTaisen() {
        calculateHogeki(baseKeyPath: "api_data.api_opening_taisen") {
            isCombinedBattle ? .second : .first
        }
    }
    fileprivate func calcHougeki1() {
        // 艦隊　戦闘艦隊
        // 連合vs通常（水上）　第１
        // 連合vs通常（機動）　第２
        // 連合vs連合（水上）　第１
        // 連合vs連合（機動）　第１
        calculateHogeki(baseKeyPath: "api_data.api_hougeki1") {
            switch battleType {
            case .combinedAir: return .second
            default: return .first
            }
        }
    }
    fileprivate func calcHougeki2() {
        // 艦隊　戦闘艦隊
        // 連合vs通常（水上）　第１
        // 連合vs通常（機動）　第１
        // 連合vs連合（水上）　第１　全体
        // 連合vs連合（機動）　第２
        calculateHogeki(baseKeyPath: "api_data.api_hougeki2") {
            switch battleType {
            case .eachCombinedWater: return .each
//            case .eachCombinedAir: return .second  // 1~12
            default: return .first
            }
        }
    }
    fileprivate func calcHougeki3() {
        // 艦隊　戦闘艦隊
        // 連合vs通常（水上）　第２
        // 連合vs通常（機動）　第１
        // 連合vs連合（水上）　第２
        // 連合vs連合（機動）　第１　全体
        calculateHogeki(baseKeyPath: "api_data.api_hougeki3") {
            switch battleType {
            case .combinedWater: return .second
//            case .eachCombinedWater: return .second  // 1~12
            case .eachCombinedAir: return .each
            default: return .first
            }
        }
    }
    fileprivate func calcRaigeki() {
        // 艦隊　戦闘艦隊
        // 連合vs通常（水上）　第２
        // 連合vs通常（機動）　第２
        // 連合vs連合（水上）　第２　全体
        // 連合vs連合（機動）　第２　全体
        calculateFDam(baseKeyPath: "api_data.api_raigeki") {
            switch battleType {
            case .combinedWater, .combinedAir: return .second
            case .eachCombinedWater, .eachCombinedAir: return .each
            default: return .first
            }
        }
    }
    
    fileprivate func calculateMidnightBattle() {
        // 艦隊　戦闘艦隊
        // 連合vs通常（水上）　第２
        // 連合vs通常（機動）　第２
        // 連合vs連合（水上）　第２
        // 連合vs連合（機動）　第２
        calculateHogeki(baseKeyPath: "api_data.api_hougeki") {
            isCombinedBattle ? .second : .first
        }
    }
}
// MARK: - Battle type
extension CalculateDamageCommand {
    fileprivate func calculateBattle() {
        updateBattleCell()
        
        calcKouku()
        calcOpeningTaisen()
        calcOpeningAttack()
        calcHougeki1()
        calcHougeki2()
        calcHougeki3()
        calcRaigeki()
    }
    fileprivate func calcCombinedBattleAir() {
        updateBattleCell()
        
        calcKouku()
        calcOpeningTaisen()
        calcOpeningAttack()
        calcHougeki1()
        calcRaigeki()
        calcHougeki2()
        calcHougeki3()
    }
    fileprivate func calcEachBattleAir() {
        updateBattleCell()
        
        calcKouku()
        calcOpeningTaisen()
        calcOpeningAttack()
        calcHougeki1()
        calcHougeki2()
        calcRaigeki()
        calcHougeki3()
    }
    fileprivate func calcEnemyCombinedBattle() {
        // same phase as combined air
        calcCombinedBattleAir()
    }
}
extension CalculateDamageCommand {

    // MARK: - Damage control
    fileprivate func damageControlIfPossible(nowhp: Int, ship: Ship) -> Int {
        var nowHp = nowhp
        if nowHp < 0 { nowHp = 0 }
        let maxhp = ship.maxhp
        let store = ServerDataStore.default
        var useDamageControl = false
        ship.equippedItem.forEach {
            if useDamageControl { return }
            guard let master = $0 as? SlotItem else { return }
            let masterSlotItemId = store.masterSlotItemID(bySlotItemId: master.id)
            guard let type = DamageControlID(rawValue: masterSlotItemId)
                else { return }
            switch type {
            case .damageControl:
                nowHp = Int(Double(maxhp) * 0.2)
                useDamageControl = true
            case .goddes:
                nowHp = maxhp
                useDamageControl = true
            }
        }
        if useDamageControl { return nowHp }
        
        let exItemId = store.masterSlotItemID(bySlotItemId: ship.slot_ex)
        guard let exType = DamageControlID(rawValue: exItemId)
            else { return nowHp }
        switch exType {
        case .damageControl:
            nowHp = Int(Double(maxhp) * 0.2)
        case .goddes:
            nowHp = maxhp
        }
        return nowHp
    }
    fileprivate func removeFirstDamageControl(of ship: Ship) {
        let equiped = ship.equippedItem
        let newEquiped = equiped.array
        let store = ServerDataStore.default
        var useDamageControl = false
        equiped.forEach {
            if useDamageControl { return }
            guard let master = $0 as? SlotItem else { return }
            let masterSlotItemId = store.masterSlotItemID(bySlotItemId: master.id)
            guard let type = DamageControlID(rawValue: masterSlotItemId)
                else { return }
            switch type {
            case .goddes:
                ship.fuel = ship.maxFuel
                ship.bull = ship.maxBull
                fallthrough
            case .damageControl:
                if var equiped = newEquiped as? [SlotItem],
                    let index = equiped.index(of: master) {
                    equiped[index...index] = []
                    ship.equippedItem = NSOrderedSet(array: equiped)
                    useDamageControl = true
                }
            }
        }
        if useDamageControl {
            return
        }
        
        let exItemId = store.masterSlotItemID(bySlotItemId: ship.slot_ex)
        guard let exType = DamageControlID(rawValue: exItemId)
            else { return }
        switch exType {
        case .goddes:
            ship.fuel = ship.maxFuel
            ship.bull = ship.maxBull
            fallthrough
        case .damageControl:
            ship.slot_ex = -1
        }
    }
}
