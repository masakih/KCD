//
//  SokuTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/04.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

private enum SokuType: Int {
    
    case slow = 5
    case fast = 10
    case faster = 15
    case fastest = 20
}

final class SokuTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        
        return NSString.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let v = value as? Int, let type = SokuType(rawValue: v)
            else { return nil }
        
        switch type {
        case .slow:
            return NSLocalizedString("Slow", comment: "Speed, slow")
            
        case .fast:
            return NSLocalizedString("Fast", comment: "Speed, fast")
            
        case .faster:
            return NSLocalizedString("Faster", comment: "Speed, faster")
            
        case .fastest:
            return NSLocalizedString("Fastest", comment: "Speed, fastest")
        }
    }
}
