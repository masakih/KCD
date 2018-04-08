//
//  ActinKindTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class ActinKindTransformer: ValueTransformer {
    
    private enum AirBaseActionKind: Int {
        
        case standBy
        
        case sortie
        
        case airDifence
        
        case shelter
        
        case rest
    }
    
    override class func transformedValueClass() -> AnyClass {
        
        return NSString.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let v = value as? Int,
            let type = AirBaseActionKind(rawValue: v) else {
                
                return nil
        }
        
        switch type {
            
        case .standBy: return LocalizedStrings.standBy.string
            
        case .sortie: return LocalizedStrings.sortie.string
            
        case .airDifence: return LocalizedStrings.airDifense.string
            
        case .shelter: return LocalizedStrings.shelter.string
            
        case .rest: return LocalizedStrings.rest.string
            
        }
    }
}
