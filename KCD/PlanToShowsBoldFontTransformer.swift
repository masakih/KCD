//
//  PlanToShowsBoldFontTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/04.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class PlanToShowsBoldFontTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> Swift.AnyClass {
        
        return NSNumber.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let v = value as? Int, v != 0 else { return false }
        
        if UserDefaults.standard[.showsPlanColor] { return true }
        
        return false
    }
}
