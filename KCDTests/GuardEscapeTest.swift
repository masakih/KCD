//
//  GuardEscapeTest.swift
//  KCDTests
//
//  Created by Hori,Masaki on 2017/12/03.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import XCTest

@testable import KCD


class GuardEscapeTest: XCTestCase {

    override func setUp() {
        super.setUp()
        
        let store = TemporaryDataStore.oneTimeEditor()
        store.guardEscaped().forEach(store.delete)
    }
    
    override func tearDown() {
        
        let store = TemporaryDataStore.oneTimeEditor()
        store.guardEscaped().forEach(store.delete)
        super.tearDown()
    }

    func testShipEntity() {
        
        let shipId = 5225
        let serverStore = ServerDataStore.default
        
        guard let ship = serverStore.ship(by: shipId) else {
            XCTFail("can not get Ship id \(shipId)")
            return
        }
        
        XCTAssertFalse(ship.guardEscaped)
        
        let tempStore = TemporaryDataStore.oneTimeEditor()
        guard let g = tempStore.createGuardEscaped() else {
            XCTFail("can not create GuardEscaped")
            return
        }
        
        g.shipID = shipId
        g.ensured = true
        
        try? tempStore.save()
        
        XCTAssertTrue(ship.guardEscaped)
    }

}
