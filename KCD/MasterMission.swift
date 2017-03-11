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
    @NSManaged var maparea_id: Int
    @NSManaged var name: String
    @NSManaged var return_flag: NSNumber?
    @NSManaged var time: NSNumber?
    @NSManaged var use_bull: NSNumber?
    @NSManaged var use_fuel: NSNumber?
    @NSManaged var win_item1_0: NSNumber?
    @NSManaged var win_item1_1: NSNumber?
    @NSManaged var win_item2_0: NSNumber?
    @NSManaged var win_item2_1: NSNumber?
}
