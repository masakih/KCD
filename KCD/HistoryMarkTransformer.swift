//
//  HistoryMarkTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HistoryMarkTransformer: ValueTransformer {
    override class func transformedValueClass() -> Swift.AnyClass {
        return NSColor.self
    }
    override func transformedValue(_ value: Any?) -> Any? {
        guard let v = value as? Bool else { return nil }
        return v ? HistoryMarkTransformer.markImage : nil
    }
    
    static var markImage: NSImage = {
        let radius: CGFloat = 10.0
        let image = NSImage(size: NSMakeSize(radius, radius))
        image.lockFocus()
        NSColor.red.highlight(withLevel: 0.6)?.set()
        NSBezierPath(roundedRect: NSMakeRect(0, 0, radius, radius),
                     xRadius: radius / 2,
                     yRadius: radius / 2)
        .fill()
        image.unlockFocus()
        
        return image
    }()
}
