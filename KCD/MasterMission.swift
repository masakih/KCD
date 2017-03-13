//
//  KCMasterMission.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/29.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

class MasterMission: KCManagedObject {
    @NSManaged var details: String?
    @NSManaged var difficulty: NSNumber?
    @NSManaged var id: Int
    @NSManaged var maparea_id: Int  // swiftlint:disable:this variable_name
    @NSManaged var name: String
    @NSManaged var return_flag: NSNumber?   // swiftlint:disable:this variable_name
    @NSManaged var time: NSNumber?
    @NSManaged var use_bull: NSNumber?  // swiftlint:disable:this variable_name
    @NSManaged var use_fuel: NSNumber?  // swiftlint:disable:this variable_name
    @NSManaged var win_item1_0: NSNumber?   // swiftlint:disable:this variable_name
    @NSManaged var win_item1_1: NSNumber?   // swiftlint:disable:this variable_name
    @NSManaged var win_item2_0: NSNumber?   // swiftlint:disable:this variable_name
    @NSManaged var win_item2_1: NSNumber?   // swiftlint:disable:this variable_name
}
