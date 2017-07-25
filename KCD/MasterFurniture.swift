//
//  MasterFurniture.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

// swiftlint:disable variable_name
final class MasterFurniture: KCManagedObject {
    
    @NSManaged var description_: String?
    @NSManaged var id: NSNumber?
    @NSManaged var no: NSNumber?
    @NSManaged var price: NSNumber?
    @NSManaged var rarity: NSNumber?
    @NSManaged var saleflg: NSNumber?
    @NSManaged var title: String?
    @NSManaged var type: NSNumber?
}
