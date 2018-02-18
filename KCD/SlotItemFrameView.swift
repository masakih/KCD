//
//  SlotItemFrameView.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class SlotItemFrameView: NSBox {
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)
        
        let bounds = self.bounds
        let width = bounds.width
        let height = bounds.height
        NSColor.gridColor.set()
        NSBezierPath.defaultLineWidth = 1.0
        
        Polygon()
            .move(to: NSPoint(x: 40.5, y: 0))
            .line(to: NSPoint(x: 40.5, y: height))
            .move(to: NSPoint(x: 0, y: 17.5))
            .line(to: NSPoint(x: width, y: 17.5))
            .move(to: NSPoint(x: 0, y: 34.5))
            .line(to: NSPoint(x: width, y: 34.5))
            .move(to: NSPoint(x: 0, y: 51.5))
            .line(to: NSPoint(x: width, y: 51.5))
            .move(to: NSPoint(x: 0, y: 68.5))
            .line(to: NSPoint(x: width, y: 68.5))
            .stroke()
    }
}
