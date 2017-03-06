//
//  DamageValueTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class DamageValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> Swift.AnyClass {
        return NSAttributedString.self
    }
    override func transformedValue(_ value: Any?) -> Any? {
        guard let v = value as? Int, let type = DamageType(rawValue: v) else { return nil }
        let attributes: (string: String, attr: [String: Any])
        switch type {
        case .none:
            return nil
        case .slightly:
            attributes = ("●",
                          [
                            NSForegroundColorAttributeName:
                                NSColor(calibratedRed: 1.0, green: 0.925, blue: 0.0, alpha: 1.0),
                            NSParagraphStyleAttributeName: paragraphStyle
                ]
            )
        case .modest:
            attributes = ("●",
                          [
                            NSForegroundColorAttributeName:
                                NSColor(calibratedRed: 1.0, green: 0.392, blue: 0.0, alpha: 1.0),
                            NSParagraphStyleAttributeName: paragraphStyle
                ]
            )
        case .badly:
            attributes = ("◼︎",
                          [
                            NSForegroundColorAttributeName:
                                NSColor(calibratedRed: 0.87, green: 0.0, blue: 0.036, alpha: 1.0),
                            NSParagraphStyleAttributeName: paragraphStyle
                ]
            )
        }
        
        return NSAttributedString(string: attributes.string, attributes: attributes.attr)
    }
    
    var paragraphStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    }()
}
