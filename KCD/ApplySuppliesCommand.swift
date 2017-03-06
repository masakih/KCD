//
//  ApplySuppliesCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class ApplySuppliesCommand: JSONCommand {
    override func execute() {
        let store = ServerDataStore.oneTimeEditor()
        guard let data = json["api_data"] as? [String: Any],
            let infos = data["api_ship"] as? [[String: Any]]
            else { return }
        infos.forEach {
            guard let i = $0["api_id"] as? Int,
                let ship = store.ship(byId: i),
                let bull = $0["api_bull"] as? Int,
                let fuel = $0["api_fuel"] as? Int,
                let slots = $0["api_onslot"] as? [Int],
                slots.count > 4
                else { return }
            ship.bull = bull
            ship.fuel = fuel
            ship.onslot_0 = slots[0]
            ship.onslot_1 = slots[1]
            ship.onslot_2 = slots[2]
            ship.onslot_3 = slots[3]
            ship.onslot_4 = slots[4]
        }
    }
}
