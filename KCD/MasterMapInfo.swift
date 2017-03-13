//
//  KCMasterMapInfo.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/29.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

class MasterMapInfo: KCManagedObject {
    @NSManaged var id: Int
    @NSManaged var infotext: String
    @NSManaged var item_0: NSNumber?    // swiftlint:disable:this variable_name
    @NSManaged var item_1: NSNumber?    // swiftlint:disable:this variable_name
    @NSManaged var item_2: NSNumber?    // swiftlint:disable:this variable_name
    @NSManaged var item_3: NSNumber?    // swiftlint:disable:this variable_name
    @NSManaged var level: NSNumber?
    @NSManaged var maparea_id: Int  // swiftlint:disable:this variable_name
    @NSManaged var max_maphp: NSNumber? // swiftlint:disable:this variable_name
    @NSManaged var name: String
    @NSManaged var no: Int
    @NSManaged var opetext: String?
    @NSManaged var required_defeat_count: NSNumber? // swiftlint:disable:this variable_name
    @NSManaged var sally_flag_0: NSNumber?  // swiftlint:disable:this variable_name
    @NSManaged var sally_flag_1: NSNumber?  // swiftlint:disable:this variable_name
}
