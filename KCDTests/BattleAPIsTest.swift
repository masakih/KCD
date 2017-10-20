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

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
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
            store.ships(byDeckId: 1).forEach {
                $0.nowhp = $0.maxhp
            }
        }
        super.tearDown()
    }

    func testNormalBattle() {
        
        // 艦隊を設定
        do {
            let store = ServerDataStore.oneTimeEditor()
            guard let deck = store.deck(by: 1) else { return XCTFail("Can not get Deck.") }
            (0...5).forEach { deck.setShip(id: $0 + 1, for: $0) }
            
            store.ships(byDeckId: 1).forEach {
                $0.nowhp = $0.maxhp
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
        
        // 戦闘
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
            
            XCTAssertEqual(ships[0].nowhp, 27)
            XCTAssertEqual(ships[1].nowhp, 25)
            XCTAssertEqual(ships[2].nowhp, 29)
            XCTAssertEqual(ships[3].nowhp, 30)
            XCTAssertEqual(ships[4].nowhp, 36)
            XCTAssertEqual(ships[5].nowhp, 30)
        }
    }

}
