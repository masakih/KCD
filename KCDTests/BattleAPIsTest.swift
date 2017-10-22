//
//  BattleAPIsTest.swift
//  KCDTests
//
//  Created by Hori,Masaki on 2017/10/19.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import XCTest

@testable import KCD

import SwiftyJSON

class BattleAPIsTest: XCTestCase {

    var savedShips: [Ship] = []
    var shipsHp: [Int] = []
    var shipEquipments: [NSOrderedSet] = []
    var shipExSlot: [Int] = []
    
    override func setUp() {
        
        super.setUp()
        
        savedShips = []
        shipsHp = []
        shipEquipments = []
        shipExSlot = []
        
        // 艦隊を設定
        do {
            let store = ServerDataStore.oneTimeEditor()
            guard let deck = store.deck(by: 1) else { return XCTFail("Can not get Deck.") }
            (0...5).forEach { deck.setShip(id: $0 + 1, for: $0) }
            
            store.ships(byDeckId: 1).forEach {
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
                "api_deck_id": "1",
                "api_maparea_id": "1",
                "api_mapinfo_no": "1"
            ]
            let param = Parameter(paramValue)
            XCTAssertEqual(param["api_deck_id"].string, "1")
            
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
        }
    }
    
    override func tearDown() {
        
        do {
            ResetSortie().reset()
        }
        
        do {
            let store = TemporaryDataStore.default
            let battle = store.battle()
            XCTAssertNil(battle)
        }
        
        do {
            let store = ServerDataStore.oneTimeEditor()
            
            guard let deck = store.deck(by: 1) else { return XCTFail("Can not get Deck.") }
            savedShips.enumerated().forEach { deck.setShip(id: $0.element.id, for: $0.offset) }
            
            
            let ships = store.ships(byDeckId: 1)
                
            zip(ships, shipsHp).forEach { $0.nowhp = $1 }
            zip(ships, shipEquipments).forEach { $0.equippedItem = $1 }
            zip(ships, shipExSlot).forEach { $0.slot_ex = $1 }
        }
        super.tearDown()
    }

    func testNormalBattle() {
        
        // 戦闘（昼戦）
        do {
            let rawValue: [String: Any] = [
                "api_result": 1,
                "api_data": [
                    "api_kouku": [
                        "api_stage3": [
                            "api_fdam": [
                                -1, 3, 0, 0, 0, 0, 0
                            ]
                        ]
                    ],
                    "api_opening_atack": [
                        "api_fdam": [
                            -1, 0, 3, 0, 0, 0, 0
                        ]
                    ],
                    "api_hougeki1": [
                        "api_df_list": [
                            -1,
                            [3, 3]
                        ],
                        "api_damage": [
                            -1,
                            [0, 1]
                        ]
                    ],
                    "api_raigeki": [
                        "api_fdam": [
                            -1, 0, 0, 0, 1, 0, 0
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
                            -1,
                            [5]
                        ],
                        "api_damage": [
                            -1,
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
            let ships = store.ships(byDeckId: 1)
            
            XCTAssertEqual(ships.count, 6)
            
            XCTAssertEqual(ships[0].nowhp, shipsHp[0] - 3)
            XCTAssertEqual(ships[1].nowhp, shipsHp[1] - 3)
            XCTAssertEqual(ships[2].nowhp, shipsHp[2] - 1)
            XCTAssertEqual(ships[3].nowhp, shipsHp[3] - 1)
            XCTAssertEqual(ships[4].nowhp, shipsHp[4] - 5)
            XCTAssertEqual(ships[5].nowhp, shipsHp[5])
        }
    }
    
    func testDamageControl() {
        
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
                            -1,
                            [4],
                            [5],
                            [6]
                        ],
                        "api_damage": [
                            -1,
                            [50],
                            [50],
                            [50]
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
            let ships = store.ships(byDeckId: 1)
            
            XCTAssertEqual(ships.count, 6)
            
            XCTAssertEqual(ships[0].nowhp, shipsHp[0])
            XCTAssertEqual(ships[1].nowhp, shipsHp[1])
            XCTAssertEqual(ships[2].nowhp, shipsHp[2])
            XCTAssertEqual(ships[3].nowhp, 0)
            XCTAssertEqual(ships[4].nowhp, shipsHp[4])
            XCTAssertEqual(ships[5].nowhp, Int(Double(shipsHp[5]) * 0.2))
        }
    }
}
