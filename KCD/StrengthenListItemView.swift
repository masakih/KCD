//
//  StrengthenListItemView.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class StrengthenListItemView: NSBox {
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)
        
        let width = bounds.width
        let height = bounds.height
        
        borderColor.set()
        NSBezierPath.defaultLineWidth = borderWidth
        NSBezierPath.stroke(bounds)
        
        Polygon()
            .move(to: NSPoint(x: 29.5, y: 0))
            .line(to: NSPoint(x: 29.5, y: height))
            .move(to: NSPoint(x: 67.5, y: 0))
            .line(to: NSPoint(x: 67.5, y: height))
            .move(to: NSPoint(x: 209.5, y: 0))
            .line(to: NSPoint(x: 209.5, y: height))
            .move(to: NSPoint(x: 0, y: 17.5))
            .line(to: NSPoint(x: width, y: 17.5))
            .move(to: NSPoint(x: 0, y: 34.5))
            .line(to: NSPoint(x: width, y: 34.5))
            .stroke()
    }
}
