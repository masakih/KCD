//
//  SlotitemNameTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/04.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class SlotitemNameTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        
        return NSString.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let id = value as? Int, id != 0, id != -1 else { return nil }
        
        return ServerDataStore.default.slotItem(by: id)?.name
    }
}
