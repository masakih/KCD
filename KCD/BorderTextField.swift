//
//  BorderTextField.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class BorderTextField: NSTextField {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let bounds = self.bounds
        let width = bounds.width
        let height = bounds.height
        NSColor.controlShadowColor.set()
        NSBezierPath.setDefaultLineWidth(1.0)
        multiline(lines:
            [
                (NSPoint(x: 3, y: height), NSPoint(x: bounds.maxX, y: height)),
                (NSPoint(x: width, y: 0), NSPoint(x: width, y: height))
            ]
            )
            .stroke()
    }
}
