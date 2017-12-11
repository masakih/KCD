//
//  RealDestroyShipCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class RealDestroyShipCommand: JSONCommand {
    
    override func execute() {
        
        let store = ServerDataStore.oneTimeEditor()
        
        let ships = parameter["api_ship_id"]
            .array
            .flatMap { $0.int }
            .flatMap(store.ship(by:))
        
        if parameter["api_slot_dest_flag"].int == 0 {
            
            // remove allEquipment
            ships.forEach {
                    $0.equippedItem = []
                    $0.extraItem = nil
            }
        }
        
        // destory ships
        ships.forEach(store.delete)
    }
}
