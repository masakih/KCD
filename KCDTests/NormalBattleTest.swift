//
//  NormalBattleTest.swift
//  KCDTests
//
//  Created by Hori,Masaki on 2017/10/19.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import XCTest

@testable import KCD

import SwiftyJSON

class NormalBattleTest: XCTestCase {
    
    var savedShips: [Ship] = []
    var shipsHp: [Int] = []
    var shipEquipments: [NSOrderedSet] = []
    var shipExSlot: [Int] = []
    
    func initBattleFleet(_ fleet: Int) {
        
        savedShips = []
        shipsHp = []
        shipEquipments = []
        shipExSlot = []
        
        // 艦隊を設定
        do {
            let store = ServerDataStore.oneTimeEditor()
            
            guard let secondFleet = store.deck(by: 2) else { return XCTFail("Can not get Deck.") }
            (0...5).forEach { secondFleet.setShip(id: $0 + 10, for: $0) }
            
            guard let deck = store.deck(by: fleet) else { return XCTFail("Can not get Deck.") }
            (0...5).forEach { deck.setShip(id: $0 + 1, for: $0) }
            
            store.ships(byDeckId: fleet).forEach {
                $0.nowhp = $0.maxhp
                
                savedShips += [$0]
                shipsHp += [$0.nowhp]
                shipEquipments += [$0.equippedItem]
                shipExSlot += [$0.slot_ex]
            }
        }
        
        // 出撃艦隊を設定
        do {
            let rawValue: [String: Any] = [
                "api_result": 1,
                "api_data": [
                    "api_no": 1
                ]
            ]
            guard let json = JSON(rawValue: rawValue) else { return XCTFail("json is nil") }
            XCTAssertNotNil(json["api_result"])
            
            let paramValue: [String: String] = [
                "api_deck_id": "\(fleet)",
                "api_maparea_id": "1",
                "api_mapinfo_no": "1"
            ]
            let param = Parameter(paramValue)
            XCTAssertEqual(param["api_deck_id"].string, "\(fleet)")
            
            let api = APIResponse(api: MapAPI.start.rawValue, parameter: param, json: json)
            XCTAssertEqual(api.json, json)
            XCTAssertEqual(api.parameter, param)
            
            let command = MapStartCommand(apiResponse: api)
            
            command.execute()
        }
        
        // battleの生成確認
        do {
            let store = TemporaryDataStore.default
            let battle = store.battle()
            XCTAssertNotNil(battle)
            XCTAssertEqual(battle?.deckId, fleet)
        }
    }
    
    func clear(_ fleet: Int) {
        
        do {
            ResetSortie().reset()
        }
        
        do {
            let store = ServerDataStore.oneTimeEditor()
            
            let ships = store.ships(byDeckId: fleet)
            
            zip(ships, shipsHp).forEach { $0.nowhp = $1 }
            zip(ships, shipEquipments).forEach { $0.equippedItem = $1 }
            zip(ships, shipExSlot).forEach { $0.slot_ex = $1 }
            
            guard let deck = store.deck(by: fleet) else { return XCTFail("Can not get Deck.") }
            savedShips.enumerated().forEach { deck.setShip(id: $0.element.id, for: $0.offset) }
        }
        
        do {
            let store = TemporaryDataStore.default
            let battle = store.battle()
            XCTAssertNil(battle)
        }
    }
    
    func normalBattle(_ fleet: Int) {
        
        // 戦闘（昼戦）
        do {
            let rawValue: [String: Any] = [
                "api_result": 1,
                "api_data": [
                    "api_kouku": [
                        "api_stage3": [
                            "api_fdam": [
                                1, 0, 0
                            ]
                        ]
                    ],
                    "api_opening_atack": [
                        "api_fdam": [
                            0, 2
                        ]
                    ],
                    "api_hougeki1": [
                        "api_df_list": [
                            [2, 2],
                            [7, 7]
                        ],
                        "api_damage": [
                            [0, 3],
                            [10, 10]
                        ]
                    ],
                    "api_raigeki": [
                        "api_fdam": [
                            0, 0, 0, 4, 0, 6
                        ]
                    ]
                ]
            ]
            guard let json = JSON(rawValue: rawValue) else { return XCTFail("json is nil") }
            let param = Parameter(["Test": "Test"])
            let api = APIResponse(api: BattleAPI.battle.rawValue, parameter: param, json: json)
            
            let command = BattleCommand(apiResponse: api)
            command.execute()
        }
        
        // 戦闘（夜戦）
        do {
            let rawValue: [String: Any] = [
                "api_result": 1,
                "api_data": [
                    "api_hougeki": [
                        "api_df_list": [
                            [4]
                        ],
                        "api_damage": [
                            [5]
                        ]
                    ]
                ]
            ]
            guard let json = JSON(rawValue: rawValue) else { return XCTFail("json is nil") }
            let param = Parameter(["Test": "Test"])
            let api = APIResponse(api: BattleAPI.midnightBattle.rawValue, parameter: param, json: json)
            
            let command = BattleCommand(apiResponse: api)
            command.execute()
        }
        
        // 艦娘HP更新
        do {
            let rawValue: [String: Any] = [
                "api_result": 1
            ]
            guard let json = JSON(rawValue: rawValue) else { return XCTFail("json is nil") }
            let param = Parameter(["Test": "Test"])
            let api = APIResponse(api: BattleAPI.battleResult.rawValue, parameter: param, json: json)
            
            let command = BattleCommand(apiResponse: api)
            command.execute()
        }
        
        // HPチェック
        do {
            let store = ServerDataStore.oneTimeEditor()
            let ships = store.ships(byDeckId: fleet)
            
            XCTAssertEqual(ships.count, 6)
            
            XCTAssertEqual(ships[0].nowhp, shipsHp[0] - 1)
            XCTAssertEqual(ships[1].nowhp, shipsHp[1] - 2)
            XCTAssertEqual(ships[2].nowhp, shipsHp[2] - 3)
            XCTAssertEqual(ships[3].nowhp, shipsHp[3] - 4)
            XCTAssertEqual(ships[4].nowhp, shipsHp[4] - 5)
            XCTAssertEqual(ships[5].nowhp, shipsHp[5] - 6)
        }
    }
    
    func damageControl(_ fleet: Int) {
        
        // ダメコンを設定
        do {
            let store = ServerDataStore.oneTimeEditor()
            
            store.ship(by: 5).flatMap {
                $0.nowhp = $0.maxhp
                $0.slot_ex = 63765  // 女神
            }
            store.ship(by: 6).flatMap {
                $0.nowhp = $0.maxhp
                // ダメコン
                $0.equippedItem = store.slotItem(by: 72418).map { NSOrderedSet(array: [$0]) } ?? []
            }
        }
        
        // 戦闘（夜戦）
        do {
            let rawValue: [String: Any] = [
                "api_result": 1,
                "api_data": [
                    "api_hougeki": [
                        "api_df_list": [
                            [3],
                            [4],
                            [5],
                            [10]
                        ],
                        "api_damage": [
                            [50],
                            [50],
                            [50],
                            [20]
                        ]
                    ]
                ]
            ]
            guard let json = JSON(rawValue: rawValue) else { return XCTFail("json is nil") }
            let param = Parameter(["Test": "Test"])
            let api = APIResponse(api: BattleAPI.midnightBattle.rawValue, parameter: param, json: json)
            
            let command = BattleCommand(apiResponse: api)
            command.execute()
        }
        
        // 艦娘HP更新
        do {
            let rawValue: [String: Any] = [
                "api_result": 1
            ]
            guard let json = JSON(rawValue: rawValue) else { return XCTFail("json is nil") }
            let param = Parameter(["Test": "Test"])
            let api = APIResponse(api: BattleAPI.battleResult.rawValue, parameter: param, json: json)
            
            let command = BattleCommand(apiResponse: api)
            command.execute()
        }
        
        // HPチェック
        do {
            let store = ServerDataStore.oneTimeEditor()
            let ships = store.ships(byDeckId: fleet)
            
            XCTAssertEqual(ships.count, 6)
            
            XCTAssertEqual(ships[0].nowhp, shipsHp[0])
            XCTAssertEqual(ships[1].nowhp, shipsHp[1])
            XCTAssertEqual(ships[2].nowhp, shipsHp[2])
            XCTAssertEqual(ships[3].nowhp, 0)
            XCTAssertEqual(ships[4].nowhp, shipsHp[4])
            XCTAssertEqual(ships[5].nowhp, Int(Double(shipsHp[5]) * 0.2))
        }
    }
    
    func testFirstFleet() {
        
        initBattleFleet(1)
        normalBattle(1)
        initBattleFleet(1)
        damageControl(1)
        clear(1)
    }
    func testSecondFleet() {
        
        initBattleFleet(2)
        normalBattle(2)
        initBattleFleet(2)
        damageControl(2)
        clear(2)
    }
    func testThiredFleet() {
        
        initBattleFleet(3)
        normalBattle(3)
        initBattleFleet(3)
        damageControl(3)
        clear(3)
    }
    func testFourthFleet() {
        
        initBattleFleet(4)
        normalBattle(4)
        initBattleFleet(4)
        damageControl(4)
        clear(4)
    }
}
