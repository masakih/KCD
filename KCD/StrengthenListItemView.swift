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
        
        let bounds = self.bounds
        let width = bounds.width
        let height = bounds.height
        
        borderColor.set()
        NSBezierPath.defaultLineWidth = borderWidth
        NSBezierPath.stroke(bounds)
        
        multiline(lines:
            [
                (NSPoint(x: 29.5, y: 0), NSPoint(x: 29.5, y: height)),
                (NSPoint(x: 67.5, y: 0), NSPoint(x: 67.5, y: height)),
                (NSPoint(x: 209.5, y: 0), NSPoint(x: 209.5, y: height)),
                (NSPoint(x: 0, y: 17.5), NSPoint(x: width, y: 17.5)),
                (NSPoint(x: 0, y: 34.5), NSPoint(x: width, y: 34.5))
            ])
            .stroke()
    }
}
