//
//  HMKenzoMark.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/30.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Foundation
import CoreData

class HMKenzoMark: NSManagedObject {

    @NSManaged var bauxite: NSNumber
    @NSManaged var bull: NSNumber
    @NSManaged var commanderLv: NSNumber
    @NSManaged var created_ship_id: NSNumber
    @NSManaged var flagShipLv: NSNumber
    @NSManaged var flagShipName: String
    @NSManaged var fuel: NSNumber
    @NSManaged var kaihatusizai: NSNumber
    @NSManaged var kDockId: NSNumber
    @NSManaged var steel: NSNumber

}
