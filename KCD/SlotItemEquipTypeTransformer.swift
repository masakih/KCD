//
//  SlotItemEquipTypeTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/04.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class SlotItemEquipTypeTransformer: ValueTransformer {
    override class func transformedValueClass() -> Swift.AnyClass {
        return String.self as! AnyClass
    }
    override func transformedValue(_ value: Any?) -> Any? {
        guard let id = value as? Int
            else { return nil }
        return ServerDataStore.default.masterSlotItemEquipType(by: id)?.name
    }
}

