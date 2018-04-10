//
//  KenzoMark.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

// swiftlint:disable identifier_name
final class KenzoMark: NSManagedObject {
    
    @NSManaged var bauxite: Int
    @NSManaged var bull: Int
    @NSManaged var commanderLv: Int
    @NSManaged var created_ship_id: Int
    @NSManaged var date: Date
    @NSManaged var flagShipLv: Int
    @NSManaged var flagShipName: String
    @NSManaged var fuel: Int
    @NSManaged var kaihatusizai: Int
    @NSManaged var kDockId: Int
    @NSManaged var steel: Int
}
