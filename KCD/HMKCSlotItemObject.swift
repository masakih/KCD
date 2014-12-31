//
//  HMKCSlotItemObject.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/31.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Foundation
import CoreData

class HMKCSlotItemObject: HMKCManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var level: NSNumber
    @NSManaged var locked: NSNumber
    @NSManaged var slotitem_id: NSNumber
    @NSManaged var equippedShip: HMKCShipObject
    @NSManaged var master_slotItem: HMKCMasterSlotItemObject

}
