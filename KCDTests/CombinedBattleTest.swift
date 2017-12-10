//
//  CombinedBattleTest.swift
//  KCDTests
//
//  Created by Hori,Masaki on 2017/11/27.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import XCTest

@testable import KCD

import SwiftyJSON

class CombinedBattleTest: XCTestCase {
    
    var savedShips: [Ship] = []
    var shipsHp: [Int] = []
    var shipEquipments: [NSOrderedSet] = []
    var shipExSlot: [Int] = []
    
    func initBattleFleet() {
        
        savedShips = []
        shipsHp = []
        shipEquipments = []
        shipExSlot = []
        
        // 艦隊を設定
        do {
            let store = ServerDataStore.oneTimeEditor()
            
            guard let deck1 = store.deck(by: 1) else { return XCTFail("Can not get Deck.") }
            (0...5).forEach { deck1.setShip(id: $0 + 1, for: $0) }
            deck1.setShip(id: 0, for: 6)
            guard let deck2 = store.deck(by: 2) else { return XCTFail("Can not get Deck.") }
            (0...5).forEach { deck2.setShip(id: $0 + 1 + 6, for: $0) }
            deck2.setShip(id: 0, for: 6)

            store.ships(byDeckId: 1).forEach {
                $0.nowhp = $0.maxhp
                
                savedShips += [$0]
                shipsHp += [$0.nowhp]
                shipEquipments += [$0.equippedItem]
                shipExSlot += [$0.slot_ex]
            }
            store.ships(byDeckId: 2).forEach {
                $0.nowhp = $0.maxhp
                
                savedShips += [$0]
                shipsHp += [$0.nowhp]
                shipEquipments += [$0.equippedItem]
                shipExSlot += [$0.slot_ex]
            }
            
            XCTAssertEqual(shipsHp.count, 12)
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
            
            let api = APIResponse(api: API(rawValue: RawAPI.start.rawValue), parameter: param, json: json)
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
            XCTAssertEqual(battle?.deckId, 1)
        }
    }
    
    func clear() {
        
        do {
            ResetSortie().reset()
        }
        
        do {
            let store = ServerDataStore.oneTimeEditor()
            
            let ships1 = store.ships(byDeckId: 1)
            
            zip(ships1, shipsHp).forEach { $0.nowhp = $1 }
            zip(ships1, shipEquipments).forEach { $0.equippedItem = $1 }
            zip(ships1, shipExSlot).forEach { $0.slot_ex = $1 }
            
            guard let deck1 = store.deck(by: 1) else { return XCTFail("Can not get Deck.") }
            savedShips.enumerated().forEach { deck1.setShip(id: $0.element.id, for: $0.offset) }
            
            let ships2 = store.ships(byDeckId: 1)
            
            zip(ships2, shipsHp[6...]).forEach { $0.nowhp = $1 }
            zip(ships2, shipEquipments[6...]).forEach { $0.equippedItem = $1 }
            zip(ships2, shipExSlot[6...]).forEach { $0.slot_ex = $1 }
            
            guard let deck2 = store.deck(by: 2) else { return XCTFail("Can not get Deck.") }
            savedShips.enumerated().forEach { deck2.setShip(id: $0.element.id, for: $0.offset) }
        }
        
        do {
            let store = TemporaryDataStore.default
            let battle = store.battle()
            XCTAssertNil(battle)
        }
    }
    
    func normalBattle() {
        
        // 戦闘（昼戦）
        do {
            let rawValue: [String: Any] = [
                "api_result": 1,
                "api_data": [
                    "api_kouku": [
                        "api_stage3": [
                            "api_fdam": [
                                1, 0, 0, 0, 0, 0    // １番艦
                            ]
                        ],
                        "api_stage3_combined": [
                            "api_fdam": [
                                2, 0, 0, 0, 0, 0    // 第二１番艦
                            ]
                        ]
                    ],
                    "api_opening_atack": [
                        "api_fdam": [
                            0, 2, 0, 0, 0, 0,       // ２番艦
                            0, 2, 0, 0, 0, 0        // 第二２番艦
                        ]
                    ],
                    "api_hougeki1": [
                        "api_df_list": [
                            [2, 2], // 3番艦
                            [7, 7],
                            [8, 8]  // 第二3番艦
                        ],
                        "api_damage": [
                            [0, 3],
                            [10, 10],
                            [0, 2]
                        ],
                        "api_at_eflag": [
                            1,
                            0,
                            1
                        ]
                    ],
                    "api_hougeki2": [
                        "api_df_list": [
                            [3, 3],  // ４番艦
                            [7, 7],
                            [9, 9]  // 第二4番艦
                        ],
                        "api_damage": [
                            [0, 4],
                            [10, 10],
                            [0, 3]
                        ],
                        "api_at_eflag": [
                            1,
                            0,
                            1
                        ]
                    ],
                    "api_hougeki3": [
                        "api_df_list": [
                            [4, 4],     // ５番艦
                            [7, 7],
                            [10, 10]      // 第二５番艦
                        ],
                        "api_damage": [
                            [0, 5],
                            [10, 10],
                            [0, 4]
                        ],
                        "api_at_eflag": [
                            1,
                            0,
                            1
                        ]
                    ],
                    "api_raigeki": [
                        "api_fdam": [
                            0, 0, 0, 0, 0, 0,
                            0, 1, 1, 1, 1, 1
                        ]
                    ]
                ]
            ]
            guard let json = JSON(rawValue: rawValue) else { return XCTFail("json is nil") }
            let param = Parameter(["Test": "Test"])
            let api = APIResponse(api: API(rawValue: RawAPI.combinedBattle.rawValue), parameter: param, json: json)
            
            let command = BattleCommand(apiResponse: api)
            command.execute()
        }
        
        do {
            let store = TemporaryDataStore.default
            let damages = store.damages()
            XCTAssertEqual(damages.count, 12)
        }
    }
    
    func midnightBattle() {
        
        // 戦闘（夜戦）
        do {
            let rawValue: [String: Any] = [
                "api_result": 1,
                "api_data": [
                    "api_hougeki": [
                        "api_df_list": [
                            [4],    // ５番艦
                            [5]     // ６番艦
                        ],
                        "api_damage": [
                            [5],
                            [7]
                        ],
                        "api_at_eflag": [
                            1,
                            1
                        ]
                    ]
                ]
            ]
            guard let json = JSON(rawValue: rawValue) else { return XCTFail("json is nil") }
            let param = Parameter(["Test": "Test"])
            let api = APIResponse(api: API(rawValue: RawAPI.combinedMidnightBattle.rawValue), parameter: param, json: json)
            
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
            let api = APIResponse(api: API(rawValue: RawAPI.combinedBattleResult.rawValue), parameter: param, json: json)
            
            let command = BattleCommand(apiResponse: api)
            command.execute()
        }
    }
    
    func checkHP() {
        
        // HPチェック
        do {
            let store = ServerDataStore.oneTimeEditor()
            let ships1 = store.ships(byDeckId: 1)
            
            XCTAssertEqual(ships1.count, 6)
            
            XCTAssertEqual(ships1[0].nowhp, shipsHp[0] - 1)
            XCTAssertEqual(ships1[1].nowhp, shipsHp[1] - 2)
            XCTAssertEqual(ships1[2].nowhp, shipsHp[2] - 3)
            XCTAssertEqual(ships1[3].nowhp, shipsHp[3] - 4)
            XCTAssertEqual(ships1[4].nowhp, shipsHp[4] - 10)
            XCTAssertEqual(ships1[5].nowhp, shipsHp[5] - 7)
            
            let ships2 = store.ships(byDeckId: 2)
            
            XCTAssertEqual(ships2.count, 6)
            
            XCTAssertEqual(ships2[0].nowhp, shipsHp[6] - 2)
            XCTAssertEqual(ships2[1].nowhp, shipsHp[7] - 3)
            XCTAssertEqual(ships2[2].nowhp, shipsHp[8] - 3)
            XCTAssertEqual(ships2[3].nowhp, shipsHp[9] - 4)
            XCTAssertEqual(ships2[4].nowhp, shipsHp[10] - 5)
            XCTAssertEqual(ships2[5].nowhp, shipsHp[11] - 1)
        }
    }
    
    func testCombined() {
        
        initBattleFleet()
        normalBattle()
        midnightBattle()
        checkHP()
        clear()
    }
}
