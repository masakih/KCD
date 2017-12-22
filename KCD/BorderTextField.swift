//
//  BorderTextField.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

/// 「編成支援」「能力値３」「艦載機搭載数」用
final class BorderTextField: NSTextField {
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)

        let bounds = self.bounds
        let width = bounds.width
        let height = bounds.height
        NSColor.controlShadowColor.set()
        NSBezierPath.defaultLineWidth = 1.0
        
        Polygon()
            .move(to: NSPoint(x: 3, y: height))
            .line(to: NSPoint(x: bounds.maxX, y: height))
            .move(to: NSPoint(x: width, y: 0))
            .line(to: NSPoint(x: width, y: height))
            .stroke()
    }
}
