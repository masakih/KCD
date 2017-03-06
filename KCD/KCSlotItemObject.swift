//
//  KCSlotItemObject.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/31.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

class KCSlotItemObject: KCManagedObject {
    @NSManaged var alv: Int
    @NSManaged var id: Int
    @NSManaged var level: Int
    @NSManaged var locked: Bool
    @NSManaged var slotitem_id: Int
    @NSManaged var equippedShip: KCShipObject?
    @NSManaged var master_slotItem: KCMasterSlotItemObject
    @NSManaged var extraEquippedShip: KCShipObject?
}

extension KCSlotItemObject {
    dynamic var name: String {
        return master_slotItem.name
    }
    dynamic var equippedShipName: String? {
        return equippedShip?.name
    }
    dynamic var equippedShipLv: NSNumber? {
        return equippedShip?.lv as NSNumber?
    }
    dynamic var masterSlotItemRare: Int {
        return master_slotItem.rare
    }
    dynamic var typeName: Int {
        return master_slotItem.type_2
    }
    dynamic var isLocked: Bool {
        return locked
    }
}
