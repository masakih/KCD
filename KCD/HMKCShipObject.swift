//
//  HMKCShipObject.swift
//  KCD
//
//  Created by Hori,Masaki on 2015/01/01.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

import Foundation
import CoreData

class HMKCShipObject: HMKCManagedObject {

    @NSManaged var bull: NSNumber
    @NSManaged var cond: NSNumber
    @NSManaged var exp: NSNumber
    @NSManaged var fuel: NSNumber
    @NSManaged var id: NSNumber
    @NSManaged var kaihi_0: NSNumber
    @NSManaged var kaihi_1: NSNumber
    @NSManaged var karyoku_0: NSNumber?
    @NSManaged var karyoku_1: NSNumber?
    @NSManaged var kyouka_0: NSNumber?
    @NSManaged var kyouka_1: NSNumber?
    @NSManaged var kyouka_2: NSNumber?
    @NSManaged var kyouka_3: NSNumber?
    @NSManaged var kyouka_4: NSNumber?
    @NSManaged var locked: NSNumber
    @NSManaged var locked_equip: NSNumber
    @NSManaged var lucky_0: NSNumber?
    @NSManaged var lucky_1: NSNumber?
    @NSManaged var lv: NSNumber
    @NSManaged var maxhp: NSNumber
    @NSManaged var ndock_time: NSNumber
    @NSManaged var nowhp: NSNumber
    @NSManaged var onslot_0: NSNumber
    @NSManaged var onslot_1: NSNumber
    @NSManaged var onslot_2: NSNumber
    @NSManaged var onslot_3: NSNumber
    @NSManaged var onslot_4: NSNumber
    @NSManaged var raisou_0: NSNumber?
    @NSManaged var raisou_1: NSNumber?
    @NSManaged var sakuteki_0: NSNumber
    @NSManaged var sakuteki_1: NSNumber
    @NSManaged var sally_area: NSNumber?
    @NSManaged var ship_id: NSNumber
    @NSManaged var slot_0: NSNumber
    @NSManaged var slot_1: NSNumber
    @NSManaged var slot_2: NSNumber
    @NSManaged var slot_3: NSNumber
    @NSManaged var slot_4: NSNumber
    @NSManaged var sortno: NSNumber
    @NSManaged var soukou_0: NSNumber?
    @NSManaged var soukou_1: NSNumber?
    @NSManaged var srate: NSNumber
    @NSManaged var taiku_0: NSNumber?
    @NSManaged var taiku_1: NSNumber?
    @NSManaged var taisen_0: NSNumber
    @NSManaged var taisen_1: NSNumber
    @NSManaged var equippedItem: NSOrderedSet
    @NSManaged var master_ship: HMKCMasterShipObject

}
