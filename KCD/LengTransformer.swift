//
//  LengTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/04.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate enum LengType: Int {
    
    case short = 1
    case middle
    case long
    case overLong
}

final class LengTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        
        return NSString.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let v = value as? Int, let type = LengType(rawValue: v)
            else { return nil }
        
        switch type {
        case .short:
            return NSLocalizedString("Short", comment: "Range, short")
            
        case .middle:
            return NSLocalizedString("Middle", comment: "Range, middle")
            
        case .long:
            return NSLocalizedString("Long", comment: "Range, long")
            
        case .overLong:
            return NSLocalizedString("Very Long", comment: "Range, very long")
        }
    }
}
