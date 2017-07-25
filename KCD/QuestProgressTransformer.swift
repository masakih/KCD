//
//  QuestProgressTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/04.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class QuestProgressTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        
        return NSString.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let v = value as? Int
            else { return nil }
        
        switch v {
        case 3:
            return "100%"
            
        case 5, 6:
            return "50%"
            
        case 9, 10:
            return "80%"
            
        default:
            return ""
        }
    }
}
