//
//  KCMasterSlotItemObject.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/29.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
final class MasterSlotItem: KCManagedObject {
    
    @NSManaged var atap: NSNumber?
    @NSManaged var bakk: NSNumber?
    @NSManaged var baku: NSNumber?
    @NSManaged var broken_0: NSNumber?
    @NSManaged var broken_1: NSNumber?
    @NSManaged var broken_2: NSNumber?
    @NSManaged var broken_3: NSNumber?
    @NSManaged var houg: NSNumber?
    @NSManaged var houk: NSNumber?
    @NSManaged var houm: NSNumber?
    @NSManaged var id: Int
    @NSManaged var info: String?
    @NSManaged var leng: NSNumber?
    @NSManaged var luck: NSNumber?
    @NSManaged var name: String
    @NSManaged var raig: NSNumber?
    @NSManaged var raik: NSNumber?
    @NSManaged var raim: NSNumber?
    @NSManaged var rare: Int
    @NSManaged var sakb: NSNumber?
    @NSManaged var saku: NSNumber?
    @NSManaged var soku: NSNumber?
    @NSManaged var sortno: NSNumber?
    @NSManaged var souk: NSNumber?
    @NSManaged var taik: NSNumber?
    @NSManaged var tais: NSNumber?
    @NSManaged var tyku: Int
    @NSManaged var type_0: Int
    @NSManaged var type_1: Int
    @NSManaged var type_2: Int
    @NSManaged var type_3: Int
    @NSManaged var slotItems: Set<SlotItem>
}
