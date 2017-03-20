//
//  BattleCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/18.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

enum BattleAPI: String {
    case battle = "/kcsapi/api_req_sortie/battle"
    
    case combinedBattle = "/kcsapi/api_req_combined_battle/battle"
    case combinedAirBattle = "/kcsapi/api_req_combined_battle/airbattle"
    case combinedBattleWater = "/kcsapi/api_req_combined_battle/battle_water"
    case combinedEcBattle = "/kcsapi/api_req_combined_battle/ec_battle"
    case combinedEachBattle = "/kcsapi/api_req_combined_battle/each_battle"
    case combinedEachBattleWater = "/kcsapi/api_req_combined_battle/each_battle_water"
    
    case airBattle = "/kcsapi/api_req_sortie/airbattle"
    case ldAirBattle = "/kcsapi/api_req_sortie/ld_airbattle"
    case combinedLdAirBattle = "/kcsapi/api_req_combined_battle/ld_airbattle"
    
    case midnightBattle = "/kcsapi/api_req_battle_midnight/battle"
    case midnightSpMidnight = "/kcsapi/api_req_battle_midnight/sp_midnight"
    case combinedEcMidnightBattle = "/kcsapi/api_req_combined_battle/ec_midnight_battle"
    case combinedMidnightBattle = "/kcsapi/api_req_combined_battle/midnight_battle"
    case combinedSpMidnight = "/kcsapi/api_req_combined_battle/sp_midnight"
    
    case battleResult = "/kcsapi/api_req_sortie/battleresult"
    case combinedBattleResult = "/kcsapi/api_req_combined_battle/battleresult"
}

class BattleCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        return BattleAPI(rawValue: api) != nil
    }
    
    override func execute() {
        CalculateDamageCommand(apiResponse: apiResponse).execute()
        
        guard let battleApi = BattleAPI(rawValue: apiResponse.api)
            else { return }
        switch battleApi {
        case .battleResult, .combinedBattleResult:
            DropShipHistoryCommand(apiResponse: apiResponse).execute()
            DummyShipCommand(apiResponse: apiResponse).execute()
            GuardShelterCommand(apiResponse: apiResponse).execute()
        default: break
        }
    }
}
