//
//  MapWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class MapWindowController: NSWindowController {
    let managedObjectContext = ServerDataStore.default.context
    
    override var windowNibName: String! {
        return "MapWindowController"
    }
}
