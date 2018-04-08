//
//  OrderedSetToArrayTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class OrderedSetToArrayTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        
        return NSArray.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let v = value as? NSOrderedSet else {
            
            return value
        }
        
        return v.array
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        
        guard let v = value as? [Any] else {
            
            return value
        }
        
        return NSOrderedSet(array: v)
    }
}
