//
//  ShipWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class ShipWindowController: NSWindowController {
    let managedObjectContext = ServerDataStore.default.context
    
    override var windowNibName: String! {
        return "ShipWindowController"
    }
    dynamic var missionFleetNumber: Int = 0
    dynamic var missionTime: NSNumber?
    
    @IBAction func changeMissionTime(_ sender: AnyObject?) {
        window?.endEditing(for: nil)
        
        let store = ServerDataStore.oneTimeEditor()
        guard let deck = store.deck(by: missionFleetNumber),
            let t = missionTime as? Double
            else { return }
        let time = Date(timeIntervalSinceNow: t).timeIntervalSince1970 * 1_000
        deck.mission_2 = Int(time)
    }
}
