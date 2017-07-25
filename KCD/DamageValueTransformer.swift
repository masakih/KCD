//
//  DamageValueTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class DamageValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        
        return NSAttributedString.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let v = value as? Int,
            let type = DamageType(rawValue: v),
            let attributes = attribute(for: type)
            else { return nil }
        
        return NSAttributedString(string: attributes.string, attributes: attributes.attr)
    }
    
    private func attribute(for type: DamageType) -> (string: String, attr: [String: Any])? {
        
        switch type {
        case .none:
            return nil
            
        case .slightly:
            return ("●",
                    [NSForegroundColorAttributeName: #colorLiteral(red: 1, green: 0.925, blue: 0, alpha: 1),
                     NSParagraphStyleAttributeName: paragraphStyle]
            )
            
        case .modest:
            return ("●",
                    [NSForegroundColorAttributeName: #colorLiteral(red: 1, green: 0.32, blue: 0, alpha: 1),
                     NSParagraphStyleAttributeName: paragraphStyle]
            )
            
        case .badly:
            return ("◼︎",
                    [NSForegroundColorAttributeName: #colorLiteral(red: 0.87, green: 0, blue: 0.036, alpha: 1),
                     NSParagraphStyleAttributeName: paragraphStyle]
            )
        }
    }
    
    private var paragraphStyle: NSParagraphStyle = {
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        return style
    }()
}
