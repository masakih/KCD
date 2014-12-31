//
//  HMKCMasterShipObject.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/01.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Foundation
import CoreData

class HMKCMasterShipObject: HMKCManagedObject {

    @NSManaged var afterbull: NSNumber
    @NSManaged var afterfuel: NSNumber
    @NSManaged var afterlv: NSNumber
    @NSManaged var aftershipid: NSNumber
    @NSManaged var backs: NSNumber
    @NSManaged var broken_0: NSNumber
    @NSManaged var broken_1: NSNumber
    @NSManaged var broken_2: NSNumber
    @NSManaged var broken_3: NSNumber
    @NSManaged var buildtime: NSNumber
    @NSManaged var bull_max: NSNumber
    @NSManaged var fuel_max: NSNumber
    @NSManaged var getmes: String
    @NSManaged var houg_0: NSNumber?
    @NSManaged var houg_1: NSNumber?
    @NSManaged var id: NSNumber
    @NSManaged var leng: NSNumber
    @NSManaged var luck_0: NSNumber?
    @NSManaged var luck_1: NSNumber?
    @NSManaged var maxeq_0: NSNumber
    @NSManaged var maxeq_1: NSNumber
    @NSManaged var maxeq_2: NSNumber
    @NSManaged var maxeq_3: NSNumber
    @NSManaged var maxeq_4: NSNumber
    @NSManaged var name: String
    @NSManaged var powup_0: NSNumber
    @NSManaged var powup_1: NSNumber
    @NSManaged var powup_2: NSNumber
    @NSManaged var powup_3: NSNumber
    @NSManaged var raig_0: NSNumber?
    @NSManaged var raig_1: NSNumber?
    @NSManaged var sinfo: String
    @NSManaged var slot_num: NSNumber
    @NSManaged var soku: NSNumber
    @NSManaged var sortno: NSNumber
    @NSManaged var souk_0: NSNumber?
    @NSManaged var souk_1: NSNumber?
    @NSManaged var taik_0: NSNumber
    @NSManaged var taik_1: NSNumber
    @NSManaged var tais_0: NSNumber
    @NSManaged var tyku_0: NSNumber?
    @NSManaged var tyku_1: NSNumber?
    @NSManaged var voicef: NSNumber
    @NSManaged var yomi: String
    @NSManaged var ships: NSSet
    @NSManaged var stype: HMKCManagedObject

}
