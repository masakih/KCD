//
//  HMKaihatuHistory.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/30.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Foundation
import CoreData

class HMKaihatuHistory: NSManagedObject {

    @NSManaged var bauxite: NSNumber
    @NSManaged var bull: NSNumber
    @NSManaged var commanderLv: NSNumber
    @NSManaged var date: NSDate
    @NSManaged var flagShipLv: NSNumber
    @NSManaged var flagShipName: String
    @NSManaged var fuel: NSNumber
    @NSManaged var kaihatusizai: NSNumber
    @NSManaged var name: String
    @NSManaged var steel: NSNumber

}
