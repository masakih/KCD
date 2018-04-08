//
//  MillisecondTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class MillisecondTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        
        return NSNumber.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let v = value as? Double else {
            
            return nil
        }
        
        return v / 1_000.0
    }
}
