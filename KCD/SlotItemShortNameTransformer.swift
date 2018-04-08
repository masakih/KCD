//
//  SlotItemShortNameTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/04.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class SlotItemShortNameTransformer: ValueTransformer {
    
    private static var slotItemShortName: [Int: String] = {
        
        guard let url = Bundle.main.url(forResource: "SlotItemShortName", withExtension: "plist"),
            let dict = NSDictionary(contentsOf: url) as? [String: String] else {
                
                fatalError("Can not load SlotItemShortName.plist")
        }
        
        return dict.reduce(into: [Int: String]()) {
            
            guard let k = Int($1.0) else {
                
                return
            }
            
            $0[k] = $1.1
        }
    }()
    
    override class func transformedValueClass() -> AnyClass {
        
        return NSString.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let id = value as? Int, id != 0, id != -1 else {
            
            return nil
        }
        
        guard let item = ServerDataStore.default.slotItem(by: id) else {
            
            return nil
        }
        
        let itemId = item.master_slotItem.id
        
        return SlotItemShortNameTransformer.slotItemShortName[itemId] ?? item.name
    }
}
