//
//  MasterUseItem.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class MasterUseItem: KCManagedObject {
    @NSManaged var category: NSNumber?
    @NSManaged var description_0: String?   // swiftlint:disable:this variable_name
    @NSManaged var description_1: String?// swiftlint:disable:this variable_name
    @NSManaged var id: Int
    @NSManaged var name: String
    @NSManaged var price: NSNumber?
    @NSManaged var usetype: NSNumber?
}
