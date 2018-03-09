//
//  TPTest.swift
//  KCDTests
//
//  Created by Hori,Masaki on 2018/03/04.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import XCTest

@testable import KCD

// 駆逐艦    5
// 軽巡洋艦    2
// 練習巡洋艦    6
// 航空巡洋艦    4
// 航空戦艦    7
// 補給艦    15
// 水上機母艦    9
// 揚陸艦    12
// 潜水空母    1
// 潜水母艦    7
//
// ドラム缶    5
// 大発動艇    8
// 特大発動艇    8
// 大発動艇（八十九式中戦車＆陸戦隊）    8
// 特大発動艇＋戦車第11連隊    8
// 特二式内火艇    22
// 戦闘糧食    1
// 秋刀魚の缶詰    1
// 戦闘糧食（特別なおにぎり）    1

class TPTest: XCTestCase {
    
    let store = ServerDataStore.oneTimeEditor()

    override func setUp() {
        super.setUp()
        
        // 駆逐艦　大潮改二
        // ドラム缶, 大発, 大発戦車
        // なし
        setupShip(id: 14, slotItems: [74_719, 11_825, 58_197], exSlot: -1, saku0: 0)
        
        // 駆逐艦 霞改二
        // なし
        // なし
        setupShip(id: 26, slotItems: [], exSlot: -1, saku0: 0)
        
        // 軽巡 由良改二
        // 大発, 大発40戦車, 特二式内火艇
        // なし
        setupShip(id: 62, slotItems: [60_172, 51_323, 9_742], exSlot: -1, saku0: 0)
        
        // 軽巡 阿武隈改二
        // なし
        // なし
        setupShip(id: 475, slotItems: [], exSlot: -1, saku0: 0)
        
        // 軽巡 鬼怒改二
        // なし
        // なし
        setupShip(id: 1_716, slotItems: [], exSlot: -1, saku0: 0)
        
        // 練巡 香取改
        // 特大発, 特大発戦車, 特二式内火艇, ドラム缶
        // なし
        setupShip(id: 15_562, slotItems: [62_546, 70_464, 50_943, 75_011], exSlot: -1, saku0: 0)
        
        // 練巡 鹿島改
        // なし
        // なし
        setupShip(id: 24_844, slotItems: [], exSlot: -1, saku0: 0)
        
        // 重巡 Prinz Eugen改
        // なし
        // おにぎり
        setupShip(id: 36_488, slotItems: [], exSlot: 70_318, saku0: 0)
        
        // 航巡 三隈改
        // なし
        // なし
        setupShip(id: 5_545, slotItems: [], exSlot: -1, saku0: 0)
        
        // 水母　千歳
        // なし
        // なし
        setupShip(id: 50_132, slotItems: [], exSlot: -1, saku0: 0)
        
        // 軽空 千代田航改二
        // 特別なおにぎり
        // なし
        setupShip(id: 88, slotItems: [80_171], exSlot: -1, saku0: 0)
        
        // 正規空母 Aquila改
        // なし
        // 鯖缶
        setupShip(id: 35_997, slotItems: [], exSlot: 37_933, saku0: 0)
        
        // 装甲空母 瑞鶴改二甲
        // なし
        // なし
        setupShip(id: 3_386, slotItems: [], exSlot: -1, saku0: 0)
        
        // 戦艦 長門改二
        // なし
        // なし
        setupShip(id: 5_500, slotItems: [], exSlot: -1, saku0: 0)
        
        // 航戦 扶桑改二
        // なし
        // なし
        setupShip(id: 602, slotItems: [], exSlot: -1, saku0: 0)
        
        // 潜水　U-511
        // なし
        // なし
        setupShip(id: 24_875, slotItems: [], exSlot: -1, saku0: 0)
        
        // 潜水空母 伊26改
        // なし
        // なし
        setupShip(id: 36_069, slotItems: [], exSlot: -1, saku0: 0)
        
        // 潜水母艦　大鯨
        // なし
        // なし
        setupShip(id: 29_953, slotItems: [], exSlot: -1, saku0: 0)
        
        // 揚陸 あきつ丸改
        // なし
        // なし
        setupShip(id: 6_036, slotItems: [], exSlot: -1, saku0: 0)
        
        // 補給 速水改
        // なし
        // なし
        setupShip(id: 21_208, slotItems: [], exSlot: -1, saku0: 0)
        
        // 工作 明石改
        // なし
        // なし
        setupShip(id: 29_268, slotItems: [], exSlot: -1, saku0: 0)
        
        // 海防 佐渡改
        // なし
        // なし
        setupShip(id: 48_510, slotItems: [], exSlot: -1, saku0: 0)
        
        
        let tempStore = TemporaryDataStore.oneTimeEditor()
        tempStore.guardEscaped().forEach(tempStore.delete)
    }
    
    override func tearDown() {
        
        let store = TemporaryDataStore.oneTimeEditor()
        store.guardEscaped().forEach(store.delete)
        super.tearDown()
    }
    
    func setupShip(id shipId: Int, slotItems: [Int], exSlot: Int, saku0: Int) {
        
        guard let ship = store.ship(by: shipId) else {
            XCTFail("Can not get ship, \(shipId)")
            fatalError()
        }
        ship.onslot_0 = ship.master_ship.maxeq_0
        ship.onslot_1 = ship.master_ship.maxeq_1
        ship.onslot_2 = ship.master_ship.maxeq_2
        ship.onslot_3 = ship.master_ship.maxeq_3
        ship.onslot_4 = ship.master_ship.maxeq_4
        
        setSlot(slotItems: slotItems, to: ship)
        
        ship.slot_ex = exSlot
        ship.extraItem = store.slotItem(by: ship.slot_ex)
        
        ship.sakuteki_0 = saku0
        
    }
    
    func setSlot(slotItems: [Int], to ship: Ship) {
        
        let newItems: [SlotItem] = slotItems
            .filter { $0 != 0 && $0 != -1 }
            .flatMap { store.slotItem(by: $0) }
        ship.equippedItem = NSOrderedSet(array: newItems)
        
        slotItems.enumerated().forEach { offset, element in
            ship.setItem(element, to: offset)
        }
    }
    
    func checkShip(_ shipId: Int, sTp: Int, bTp: Double) {
        
        guard let ship1 = store.ship(by: shipId) else {
            XCTFail("Can not get ship")
            fatalError()
        }
        ship1.nowhp = ship1.maxhp
        let tp = ShipTPValueCalculator(ship1).value
        XCTAssertEqual(tp, sTp)
        XCTAssertLessThan(Double(tp) * 0.7 - bTp, 0.0001)
        
        // 大破
        ship1.nowhp = Int(Double(ship1.nowhp) * 0.2)
        XCTAssertEqual(ShipTPValueCalculator(ship1).value, 0)
    }

    func testTP() {
        
        // 駆逐艦　大潮改二
        checkShip(14, sTp: 26, bTp: 18.2)
        
        // 駆逐艦 霞改二
        checkShip(26, sTp: 5, bTp: 3.5)
        
        // 軽巡 由良改二
        checkShip(62, sTp: 40, bTp: 28)
        
        // 軽巡 阿武隈改二
        checkShip(475, sTp: 2, bTp: 1.4)
        
        // 練巡 香取改
        checkShip(15_562, sTp: 49, bTp: 34.3)
        
        // 練巡 鹿島改
        checkShip(24_844, sTp: 6, bTp: 4.2)
        
        // 重巡 Prinz Eugen改
        checkShip(36_488, sTp: 1, bTp: 0.7)
        
        // 航巡 三隈改
        checkShip(5_545, sTp: 4, bTp: 2.8)
        
        // 水母　千歳
        checkShip(50_132, sTp: 9, bTp: 6.3)
        
        // 軽空 千代田航改二
        checkShip(88, sTp: 1, bTp: 0.7)
        
        // 正規空母 Aquila改
        checkShip(35_997, sTp: 1, bTp: 0.7)
        
        // 装甲空母 瑞鶴改二甲
        checkShip(3_386, sTp: 0, bTp: 0)
        
        // 戦艦 長門改二
        checkShip(5_500, sTp: 0, bTp: 0)
        
        // 航戦 扶桑改二
        checkShip(602, sTp: 7, bTp: 4.9)
        
        // 潜水　U-511
        checkShip(24_875, sTp: 0, bTp: 0)
        
        // 潜水空母 伊26改
        checkShip(36_069, sTp: 1, bTp: 0.7)
        
        // 潜水母艦　大鯨
        checkShip(29_953, sTp: 7, bTp: 4.9)
        
        // 揚陸 あきつ丸改
        checkShip(6_036, sTp: 12, bTp: 8.4)
        
        // 補給 速水改
        checkShip(21_208, sTp: 15, bTp: 10.5)
        
        // 工作 明石改
        checkShip(29_268, sTp: 0, bTp: 0)
        
        // 海防 佐渡改
        checkShip(48_510, sTp: 0, bTp: 0)
    }
}
