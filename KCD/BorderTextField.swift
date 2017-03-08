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
        let width = NSWidth(bounds)
        let height = NSHeight(bounds)
        NSColor.controlShadowColor.set()
        NSBezierPath.setDefaultLineWidth(1.0)
        multiline {
            [(NSPoint, NSPoint)]()
                .appended { (NSPoint(x: 3, y: height), NSPoint(x: NSMaxX(bounds), y: height)) }
                .appended { (NSPoint(x: width, y: 0), NSPoint(x: width, y: height)) }
            }
            .map { $0.stroke() }
    }
}
