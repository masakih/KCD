//
//  KCMasterMapInfo.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/29.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

// swiftlint:disable variable_name
final class MasterMapInfo: KCManagedObject {
    
    @NSManaged var id: Int
    @NSManaged var infotext: String
    @NSManaged var item_0: NSNumber?
    @NSManaged var item_1: NSNumber?
    @NSManaged var item_2: NSNumber?
    @NSManaged var item_3: NSNumber?
    @NSManaged var level: NSNumber?
    @NSManaged var maparea_id: Int
    @NSManaged var max_maphp: NSNumber?
    @NSManaged var name: String
    @NSManaged var no: Int
    @NSManaged var opetext: String?
    @NSManaged var required_defeat_count: NSNumber?
    @NSManaged var sally_flag_0: NSNumber?
    @NSManaged var sally_flag_1: NSNumber?
}
