//
//  KaihatuHistory.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/01.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation
import CoreData

final class KaihatuHistory: NSManagedObject {
    
    @NSManaged var bull: Int
    @NSManaged var bauxite: Int
    @NSManaged var date: Date
    @NSManaged var fuel: Int
    @NSManaged var name: String
    @NSManaged var steel: Int
    @NSManaged var kaihatusizai: Int
    @NSManaged var flagShipName: String
    @NSManaged var flagShipLv: Int
    @NSManaged var commanderLv: Int
    @NSManaged var mark: Bool
}
