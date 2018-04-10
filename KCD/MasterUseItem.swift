//
//  MasterUseItem.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

// swiftlint:disable identifier_name
final class MasterUseItem: KCManagedObject {
    
    @NSManaged var category: NSNumber?
    @NSManaged var description_0: String?
    @NSManaged var description_1: String?
    @NSManaged var id: Int
    @NSManaged var name: String
    @NSManaged var price: NSNumber?
    @NSManaged var usetype: NSNumber?
}
