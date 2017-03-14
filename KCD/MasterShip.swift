//
//  KCMasterShipObject.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/29.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

// swiftlint:disable variable_name
class MasterShip: KCManagedObject {
    @NSManaged var afterbull: NSNumber?
    @NSManaged var afterfuel: NSNumber?
    @NSManaged var afterlv: Int
    @NSManaged var aftershipid: Int
    @NSManaged var backs: NSNumber?
    @NSManaged var broken_0: NSNumber?
    @NSManaged var broken_1: NSNumber?
    @NSManaged var broken_2: NSNumber?
    @NSManaged var broken_3: NSNumber?
    @NSManaged var buildtime: NSNumber?
    @NSManaged var bull_max: Int
    @NSManaged var fuel_max: Int
    @NSManaged var getmes: NSNumber?
    @NSManaged var houg_0: Int
    @NSManaged var houg_1: Int
    @NSManaged var id: Int
    @NSManaged var leng: Int
    @NSManaged var luck_0: Int
    @NSManaged var luck_1: Int
    @NSManaged var maxeq_0: Int
    @NSManaged var maxeq_1: Int
    @NSManaged var maxeq_2: Int
    @NSManaged var maxeq_3: Int
    @NSManaged var maxeq_4: Int
    @NSManaged var name: String
    @NSManaged var powup_0: Int
    @NSManaged var powup_1: Int
    @NSManaged var powup_2: Int
    @NSManaged var powup_3: Int
    @NSManaged var raig_0: Int
    @NSManaged var raig_1: Int
    @NSManaged var sinfo: String?
    @NSManaged var slot_num: Int
    @NSManaged var soku: Int
    @NSManaged var sortno: NSNumber?
    @NSManaged var souk_0: Int
    @NSManaged var souk_1: Int
    @NSManaged var taik_0: Int
    @NSManaged var taik_1: Int
    @NSManaged var tais_0: NSNumber?
    @NSManaged var tyku_0: Int
    @NSManaged var tyku_1: Int
    @NSManaged var voicef: NSNumber?
    @NSManaged var yomi: String?
    @NSManaged var ships: Set<Ship>
    @NSManaged var stype: MasterSType
}
