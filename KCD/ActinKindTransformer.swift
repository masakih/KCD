//
//  ActinKindTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

private enum AirBaseActionKind: Int {
    
    case standBy
    case sortie
    case airDifence
    case shelter
    case rest
}

final class ActinKindTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        
        return NSString.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let v = value as? Int,
            let type = AirBaseActionKind(rawValue: v) else {
                
                return nil
        }
        
        switch type {
        case .standBy:
            return NSLocalizedString("StandBy", comment: "Airbase action kind")
            
        case .sortie:
            return NSLocalizedString("Sortie", comment: "Airbase action kind")
            
        case .airDifence:
            return NSLocalizedString("Air Difence", comment: "Airbase action kind")
            
        case .shelter:
            return NSLocalizedString("Shelter", comment: "Airbase action kind")
            
        case .rest:
            return NSLocalizedString("Rest", comment: "Airbase action kind")
        }
    }
}
