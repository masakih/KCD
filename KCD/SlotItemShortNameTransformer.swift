//
//  SlotItemShortNameTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/04.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class SlotItemShortNameTransformer: ValueTransformer {
    
    private static var slotItemShortName: [Int: String] = {
        guard let url = Bundle.main.url(forResource: "SlotItemShortName", withExtension: "plist"),
            let dict = NSDictionary(contentsOf: url) as? [String: String]
            else { fatalError("Can not load SlotItemShortName.plist") }
        return dict.reduce([Int: String]()) {
            guard let k = Int($1.0) else { return $0 }
            var d = $0
            d[k] = $1.1
            return d
        }
    }()
    
    override class func transformedValueClass() -> Swift.AnyClass {
        return String.self as! AnyClass
    }
    override func transformedValue(_ value: Any?) -> Any? {
        guard let id = value as? Int, id != 0, id != -1 else { return nil }
        guard let item = ServerDataStore.default.slotItem(byId: id)
            else { return nil }
        let itemId = item.master_slotItem.id
        return SlotItemShortNameTransformer.slotItemShortName[itemId] ?? item.name
    }
}
