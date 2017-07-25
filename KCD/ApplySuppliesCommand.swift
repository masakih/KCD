//
//  ApplySuppliesCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class ApplySuppliesCommand: JSONCommand {
    
    override func execute() {
        
        let store = ServerDataStore.oneTimeEditor()
        
        data["api_ship"]
            .forEach { (_, json) in
                
                guard let i = json["api_id"].int,
                    let ship = store.ship(by: i),
                    let bull = json["api_bull"].int,
                    let fuel = json["api_fuel"].int,
                    let slots = json["api_onslot"].arrayObject as? [Int],
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
