//
//  ShipStatusTest.swift
//  KCDTests
//
//  Created by Hori,Masaki on 2017/10/24.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import XCTest

@testable import KCD

class ShipStatusTest: XCTestCase {

    func testLimitShipStatus() {
        
        let store = ServerDataStore.oneTimeEditor()
        
        guard let ship = store.ship(by: 1) else { return XCTFail("Can not get ship 1.") }
        
        ship.maxhp = 30
        
        ship.nowhp = 23
        XCTAssertEqual(ship.status, 0)
        ship.nowhp = 22
        XCTAssertEqual(ship.status, 1)
        ship.nowhp = 16
        XCTAssertEqual(ship.status, 1)
        ship.nowhp = 15
        XCTAssertEqual(ship.status, 2)
        ship.nowhp = 8
        XCTAssertEqual(ship.status, 2)
        ship.nowhp = 7
        XCTAssertEqual(ship.status, 3)
        
        ship.maxhp = 31
        
        ship.nowhp = 24
        XCTAssertEqual(ship.status, 0)
        ship.nowhp = 23
        XCTAssertEqual(ship.status, 1)
        ship.nowhp = 16
        XCTAssertEqual(ship.status, 1)
        ship.nowhp = 15
        XCTAssertEqual(ship.status, 2)
        ship.nowhp = 8
        XCTAssertEqual(ship.status, 2)
        ship.nowhp = 7
        XCTAssertEqual(ship.status, 3)
        
    }
}
