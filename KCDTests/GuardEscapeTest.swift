//
//  GuardEscapeTest.swift
//  KCDTests
//
//  Created by Hori,Masaki on 2017/12/03.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import XCTest

@testable import KCD

import SwiftyJSON

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
    
    // 護衛退避
    func testGuardShelter() {
        
        // 艦隊を設定
        do {
            let store = ServerDataStore.oneTimeEditor()
            
            guard let deck1 = store.deck(by: 1) else { return XCTFail("Can not get Deck.") }
            (0...5).forEach { deck1.setShip(id: $0 + 1, for: $0) }
            guard let deck2 = store.deck(by: 2) else { return XCTFail("Can not get Deck.") }
            (0...5).forEach { deck2.setShip(id: $0 + 1 + 6, for: $0) }
        }
        
        // Battle生成
        do {
            
            let store = TemporaryDataStore.oneTimeEditor()
            store.guardEscaped().forEach(store.delete)
            store.battles().forEach(store.delete)
            guard let battle = store.createBattle() else {
                XCTFail("Can not create battle")
                return
            }
            
            battle.deckId = 1
        }
        
        do {
            let rawValue: [String: Any] = [
                "api_result": 1,
                "api_data": [
                    "api_escape": [
                        "api_escape_idx": [9, 12],
                        "api_tow_idx": [10]
                    ]
                ]
            ]
            
            guard let json = JSON(rawValue: rawValue) else { return XCTFail("json is nil") }
            let param = Parameter(["Test": "Test"])
            let resultApi = APIResponse(api: API(rawValue: RawAPI.battleResult.rawValue), parameter: param, json: json)
            GuardShelterCommand(apiResponse: resultApi).execute()
            
            let goBackApi = APIResponse(api: API(rawValue: RawAPI.goback.rawValue), parameter: param, json: json)
            GuardShelterCommand(apiResponse: goBackApi).execute()
        }
        
        do {
            
            let store = ServerDataStore.default
            let ships1 = store.ships(byDeckId: 1)
            XCTAssertEqual(ships1.count, 6)
            XCTAssertEqual(ships1[0].guardEscaped, false)
            XCTAssertEqual(ships1[1].guardEscaped, false)
            XCTAssertEqual(ships1[2].guardEscaped, false)
            XCTAssertEqual(ships1[3].guardEscaped, false)
            XCTAssertEqual(ships1[4].guardEscaped, false)
            XCTAssertEqual(ships1[5].guardEscaped, false)
            
            let ships2 = store.ships(byDeckId: 2)
            XCTAssertEqual(ships2.count, 6)
            XCTAssertEqual(ships2[0].guardEscaped, false)
            XCTAssertEqual(ships2[1].guardEscaped, false)
            XCTAssertEqual(ships2[2].guardEscaped, true)
            XCTAssertEqual(ships2[3].guardEscaped, true)
            XCTAssertEqual(ships2[4].guardEscaped, false)
            XCTAssertEqual(ships2[5].guardEscaped, false)
        }
        
        do {
            let store = TemporaryDataStore.oneTimeEditor()
            store.guardEscaped().forEach(store.delete)
            store.battles().forEach(store.delete)
        }
    }
    
    // 単艦退避
    func testShelter() {
        
        // 艦隊を設定
        do {
            let store = ServerDataStore.oneTimeEditor()
            
            guard let deck1 = store.deck(by: 3) else { return XCTFail("Can not get Deck.") }
            (0...6).forEach { deck1.setShip(id: $0 + 5, for: $0) }
        }
        
        // Battle生成
        do {
            
            let store = TemporaryDataStore.oneTimeEditor()
            store.guardEscaped().forEach(store.delete)
            store.battles().forEach(store.delete)
            guard let battle = store.createBattle() else {
                XCTFail("Can not create battle")
                return
            }
            
            battle.deckId = 3
        }
        
        do {
            let rawValue: [String: Any] = [
                "api_result": 1,
                "api_data": [
                    "api_escape": [
                        "api_escape_idx": [3, 4]
                    ]
                ]
            ]
            
            guard let json = JSON(rawValue: rawValue) else { return XCTFail("json is nil") }
            let param = Parameter(["Test": "Test"])
            let resultApi = APIResponse(api: API(rawValue: RawAPI.battleResult.rawValue), parameter: param, json: json)
            GuardShelterCommand(apiResponse: resultApi).execute()
            
            let goBackApi = APIResponse(api: API(rawValue: RawAPI.gobakAlone.rawValue), parameter: param, json: json)
            GuardShelterCommand(apiResponse: goBackApi).execute()
        }
        
        do {
            
            let store = ServerDataStore.default
            let ships1 = store.ships(byDeckId: 3)
            XCTAssertEqual(ships1.count, 7)
            XCTAssertEqual(ships1[0].guardEscaped, false)
            XCTAssertEqual(ships1[1].guardEscaped, false)
            XCTAssertEqual(ships1[2].guardEscaped, true)
            XCTAssertEqual(ships1[3].guardEscaped, false)
            XCTAssertEqual(ships1[4].guardEscaped, false)
            XCTAssertEqual(ships1[5].guardEscaped, false)
            XCTAssertEqual(ships1[6].guardEscaped, false)

        }
        
        do {
            let store = TemporaryDataStore.oneTimeEditor()
            store.guardEscaped().forEach(store.delete)
            store.battles().forEach(store.delete)
        }
    }

}
