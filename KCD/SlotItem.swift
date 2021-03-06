//
//  KCSlotItemObject.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/31.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
final class SlotItem: KCManagedObject {
    
    @NSManaged var alv: Int
    @NSManaged var id: Int
    @NSManaged var level: Int
    @NSManaged var locked: Bool
    @NSManaged var slotitem_id: Int
    @NSManaged var equippedShip: Ship?
    @NSManaged var master_slotItem: MasterSlotItem
    @NSManaged var extraEquippedShip: Ship?
}
// swiftlint:eable identifier_name

extension SlotItem {
    
    @objc dynamic var name: String {
        
        return master_slotItem.name
    }
    
    private var equippedOrExShip: Ship? {
        
        return [equippedShip, extraEquippedShip].compactMap { $0 }.first
    }
    
    @objc dynamic var equippedShipName: String? {
        
        return equippedOrExShip?.name
    }
    
    @objc dynamic var equippedShipLv: NSNumber? {
        
        return equippedOrExShip?.lv as NSNumber?
    }
    
    @objc dynamic var masterSlotItemRare: Int {
        
        return master_slotItem.rare
    }
    
    @objc dynamic var typeName: Int {
        
        return master_slotItem.type_2
    }
    
    @objc dynamic var isLocked: Bool {
        
        return locked
    }
}
