//
//  DamageCalculator.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/07/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import SwiftyJSON

// MARK: - Primitive Calclator
extension CalculateDamageCommand {
    private func hogekiTargets(_ list: JSON) -> [[Int]]? {
        guard let targetArraysArray = list
            .array?
            .flatMap({ $0.array?.flatMap { $0.int } })
            else { return nil }
        guard list.count - 1 == targetArraysArray.count
            else {
                print("api_df_list is wrong")
                return nil
        }
        return targetArraysArray
    }
    private func hogekiDamages(_ list: JSON) -> [[Int]]? {
        return list.array?.flatMap { $0.array?.flatMap { $0.int } }
    }
    private func enemyFlags(_ list: JSON) -> [Int]? {
        return list.array?.flatMap { $0.int }.filter { $0 != -1 }
    }
    private func isTargetFriend(eFlags: [Int]?, index: Int) -> Bool {
        if let eFlags = eFlags, 0..<eFlags.count ~= index {
            return eFlags[index] == 1
        }
        return true
    }
    private func validTargetPos(_ targetPos: Int, in battleFleet: BattleFleet) -> Bool {
        let upper = (battleFleet == .each ? 12 : 6)
        return 1...upper ~= targetPos
    }
    private func position(_ pos: Int, in fleet: BattleFleet) -> Int? {
        let shipOffset = (fleet == .second) ? 6 : 0
        let damagePos = pos - 1 + shipOffset
        guard 0..<damages.count ~= damagePos
            else { return nil }
        return damagePos
    }
    private func calcHP(damage: Damage, receive: Int) {
        let hp = damage.hp as Int
        var newHP = hp - receive
        if newHP <= 0 {
            let shipId = damage.shipID
            if let ship = ServerDataStore.default.ship(by: shipId) {
                let efectiveHP = damageControlIfPossible(nowhp: newHP, ship: ship)
                if efectiveHP != 0, efectiveHP != newHP {
                    damage.useDamageControl = true
                }
                newHP = efectiveHP
            }
        }
        damage.hp = newHP
    }
    fileprivate func calculateHogeki(baseKeyPath: String, _ bf: () -> BattleFleet) {
        calculateHogeki(baseKeyPath: baseKeyPath, battleFleet: bf())
    }
    fileprivate func calculateHogeki(baseKeyPath: String, battleFleet: BattleFleet = .first) {
        let baseValue = json[baseKeyPath.components(separatedBy: ".")]
        guard let targetPosLists = hogekiTargets(baseValue["api_df_list"]),
            let damageLists = hogekiDamages(baseValue["api_damage"])
            else { return }
        guard targetPosLists.count == damageLists.count
            else { return print("api_damage is wrong.") }
        
        let eFlags = enemyFlags(baseValue["api_at_eflag"])
        
        Debug.print("Start Hougeki \(baseKeyPath)", level: .debug)
        zip(targetPosLists, damageLists).enumerated().forEach { (i, list) in
            if !isTargetFriend(eFlags: eFlags, index: i) { return }
            
            zip(list.0, list.1).forEach { (targetPos, damage) in
                guard validTargetPos(targetPos, in: battleFleet) else { return }
                
                guard let damagePos = position(targetPos, in: battleFleet)
                    else { return print("damage pos is larger than damage count") }
                calcHP(damage: damages[damagePos], receive: damage)
                
                Debug.excute(level: .debug) {
                    let shipOffset = (battleFleet == .second) ? 6 : 0
                    print("Hougeki \(targetPos + shipOffset) -> \(damage)")
                }
            }
        }
    }
    fileprivate func calculateFDam(baseKeyPath: String, _ bf: () -> BattleFleet) {
        calculateFDam(baseKeyPath: baseKeyPath, battleFleet: bf())
    }
    fileprivate func calculateFDam(baseKeyPath: String, battleFleet: BattleFleet = .first) {
        let baseValue = json[baseKeyPath.components(separatedBy: ".")]
        guard let koukuDamages = baseValue["api_fdam"].arrayObject as? [Int]
            else { return }
        
        Debug.print("Start FDam \(baseKeyPath)", level: .debug)
        
        koukuDamages.enumerated().forEach { (idx, damage) in
            if idx == 0 { return }
            
            guard let damagePos = position(idx, in: battleFleet)
                else { return }
            calcHP(damage: damages[damagePos], receive: damage)
            
            Debug.excute(level: .debug) {
                let shipOffset = (battleFleet == .second) ? 6 : 0
                print("FDam \(idx + shipOffset) -> \(damage)")
            }
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
    func calculateBattle() {
        updateBattleCell()
        
        calcKouku()
        calcOpeningTaisen()
        calcOpeningAttack()
        calcHougeki1()
        calcHougeki2()
        calcHougeki3()
        calcRaigeki()
    }
    func calcCombinedBattleAir() {
        updateBattleCell()
        
        calcKouku()
        calcOpeningTaisen()
        calcOpeningAttack()
        calcHougeki1()
        calcRaigeki()
        calcHougeki2()
        calcHougeki3()
    }
    func calcEachBattleAir() {
        updateBattleCell()
        
        calcKouku()
        calcOpeningTaisen()
        calcOpeningAttack()
        calcHougeki1()
        calcHougeki2()
        calcRaigeki()
        calcHougeki3()
    }
    func calcEnemyCombinedBattle() {
        // same phase as combined air
        calcCombinedBattleAir()
    }
    func calcMidnight() {
        calculateMidnightBattle()
    }
}
// MARK: - Damage control
extension CalculateDamageCommand {
    fileprivate func damageControlIfPossible(nowhp: Int, ship: Ship) -> Int {
        var nowHp = nowhp
        if nowHp < 0 { nowHp = 0 }
        let maxhp = ship.maxhp
        let store = ServerDataStore.default
        var useDamageControl = false
        ship.equippedItem.forEach {
            if useDamageControl { return }
            guard let master = $0 as? SlotItem else { return }
            let masterSlotItemId = store.masterSlotItemID(by: master.id)
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
        // check extra slot
        let exItemId = store.masterSlotItemID(by: ship.slot_ex)
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
    func removeFirstDamageControl(of ship: Ship) {
        let equiped = ship.equippedItem
        let newEquiped = equiped.array
        let store = ServerDataStore.default
        var useDamageControl = false
        equiped.forEach {
            if useDamageControl { return }
            guard let master = $0 as? SlotItem else { return }
            let masterSlotItemId = store.masterSlotItemID(by: master.id)
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
        if useDamageControl { return }
        // check extra slot
        let exItemId = store.masterSlotItemID(by: ship.slot_ex)
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
