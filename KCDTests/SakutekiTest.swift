//
//  SakutekiTest.swift
//  KCDTests
//
//  Created by Hori,Masaki on 2017/12/24.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import XCTest

@testable import KCD

class SakutekiTest: XCTestCase {
    
    let store = ServerDataStore.oneTimeEditor()
    
    override func setUp() {
        
        super.setUp()
        
        // 千歳航改二
        // 天山一二型（村田隊）, 流星（六○一空）,彩雲（東カロリン空）,零式艦戦５３型（岩本隊）
        // Bofors 40mm四連装機関砲
        setupShip(id: 228, slotItems: [36_082, 28_114, 67_268, 17_930], exSlot: 51_387, saku0: 108)
        
        // 熊野改二
        // 紫雲, 零式水上偵察機11型乙, 強風改, 二式水戦改
        // なし
        setupShip(id: 4_184, slotItems: [65_505, 72_413, 70_952, 69_442], exSlot: 0, saku0: 110)
        
        // 筑摩改二
        // 二式水戦改, ３２号対水上電探+8, FuMO25レーダー, 零式水上観測機+6
        // なし
        setupShip(id: 220, slotItems: [47_272, 26_065, 61_168, 13_621], exSlot: 0, saku0: 130)
        
        
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
    
    // 小数点第２位以下切り捨て
    func fitSakuteki(_ sakuteki: Double) -> Double {
        
        return Double(Int(sakuteki * 10)) / 10
    }

    func testOneShip() {
        
        // 千歳航改二
        guard let ship = store.ship(by: 228) else {
            
            XCTFail("Can not get ship")
            
            fatalError()
        }
        
        XCTAssertEqual(SimpleCalculator().calculate([ship]), 108)
        
        XCTAssertEqual(fitSakuteki(Formula33(1).calculate([ship])), -11.2)
        XCTAssertEqual(fitSakuteki(Formula33(3).calculate([ship])), 23.5)
        XCTAssertEqual(fitSakuteki(Formula33(4).calculate([ship])), 40.9)
    }
    
    func testOne2Ship() {
        
        // 熊野改二
        guard let ship = store.ship(by: 4_184) else {
            
            XCTFail("Can not get ship")
            
            fatalError()
        }
        
        XCTAssertEqual(SimpleCalculator().calculate([ship]), 110)
        
        XCTAssertEqual(fitSakuteki(Formula33(1).calculate([ship])), -10.3)
        XCTAssertEqual(fitSakuteki(Formula33(3).calculate([ship])), 25.6)
        XCTAssertEqual(fitSakuteki(Formula33(4).calculate([ship])), 43.6)
    }
    
    func testTwoShips() {
        
        // 千歳航改二
        guard let ship1 = store.ship(by: 228) else {
            
            XCTFail("Can not get ship")
            
            fatalError()
        }
        // 熊野改二
        guard let ship2 = store.ship(by: 4_184) else {
            
            XCTFail("Can not get ship")
            
            fatalError()
        }
        
        XCTAssertEqual(SimpleCalculator().calculate([ship1, ship2]), 218)
        
        XCTAssertEqual(fitSakuteki(Formula33(1).calculate([ship1, ship2])), 14.4)
        XCTAssertEqual(fitSakuteki(Formula33(3).calculate([ship1, ship2])), 85.2)
        XCTAssertEqual(fitSakuteki(Formula33(4).calculate([ship1, ship2])), 120.6)
    }
    
    func testTreeShips() {
        
        // 千歳航改二
        guard let ship1 = store.ship(by: 228) else {
            
            XCTFail("Can not get ship")
            
            fatalError()
        }
        // 熊野改二
        guard let ship2 = store.ship(by: 4_184) else {
            
            XCTFail("Can not get ship")
            
            fatalError()
        }
        // 筑摩改二
        guard let ship3 = store.ship(by: 220) else {
            
            XCTFail("Can not get ship")
            
            fatalError()
        }
        
        XCTAssertEqual(SimpleCalculator().calculate([ship1, ship2, ship3]), 348)
        
        XCTAssertEqual(fitSakuteki(Formula33(1).calculate([ship1, ship2, ship3])), 47.9)
        XCTAssertEqual(fitSakuteki(Formula33(3).calculate([ship1, ship2, ship3])), 169.2)
        XCTAssertEqual(fitSakuteki(Formula33(4).calculate([ship1, ship2, ship3])), 229.8)
    }
    
    func testEscapedShips() {
        
        // 千歳航改二
        guard let ship1 = store.ship(by: 228) else {
            
            XCTFail("Can not get ship")
            
            fatalError()
        }
        // 熊野改二
        guard let ship2 = store.ship(by: 4_184) else {
            
            XCTFail("Can not get ship")
            
            fatalError()
        }
        // 筑摩改二
        guard let ship3 = store.ship(by: 220) else {
            
            XCTFail("Can not get ship")
            
            fatalError()
        }
        
        // 熊野改二を退避
        do {
            
            let tempStore = TemporaryDataStore.oneTimeEditor()
            let guardEscape = tempStore.createGuardEscaped()
            guardEscape?.shipID = 4_184
            guardEscape?.ensured = true
        }
        
        XCTAssertEqual(SimpleCalculator().calculate([ship1, ship2, ship3]), 238)
        
        XCTAssertEqual(fitSakuteki(Formula33(1).calculate([ship1, ship2, ship3])), 22.2)
        XCTAssertEqual(fitSakuteki(Formula33(3).calculate([ship1, ship2, ship3])), 107.5)
        XCTAssertEqual(fitSakuteki(Formula33(4).calculate([ship1, ship2, ship3])), 150.1)
    }
}
