//
//  KenzoHistory.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/01.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation
import CoreData

class KenzoHistory: NSManagedObject {
    @NSManaged var bauxite: Int
    @NSManaged var bull: Int
    @NSManaged var date: Date
    @NSManaged var fuel: Int
    @NSManaged var kaihatusizai: Int
    @NSManaged var name: String
    @NSManaged var steel: Int
    @NSManaged var sTypeId: Int
    @NSManaged var flagShipName: String
    @NSManaged var flagShipLv: Int
    @NSManaged var commanderLv: Int
    @NSManaged var mark: Bool
}

extension KenzoHistory {
    dynamic var isLarge: Bool { return fuel > 999 }
}
