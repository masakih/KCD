//
//  LengTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/04.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class LengTransformer: ValueTransformer {
    
    private enum LengType: Int {
        
        case short = 1
        case middle
        case long
        case overLong
    }
    
    override class func transformedValueClass() -> AnyClass {
        
        return NSString.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let v = value as? Int, let type = LengType(rawValue: v) else { return nil }
        
        switch type {
        case .short: return LocalizedStrings.short.string
            
        case .middle: return LocalizedStrings.middle.string
            
        case .long: return LocalizedStrings.long.string
            
        case .overLong: return LocalizedStrings.overLong.string
        }
    }
}
