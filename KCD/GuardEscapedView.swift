//
//  GuardEscapedView.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/03.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class GuardEscapedView: NSView {
    private static var taihiStrings: String = {
        guard let url = Bundle.main.url(forResource: "Taihi", withExtension: "txt"),
            let taihiString = try? String(contentsOf: url, encoding: .utf8)
            else { fatalError("Can not load Taihi.txt") }
        guard (taihiString as NSString).length == 2 else { fatalError("Taihi string is not 2 charactor") }
         return taihiString
    }()
    
    var controlSize: NSControlSize = .regular
    private var taiString: String {
        let s = GuardEscapedView.taihiStrings
        let range = s.index(s.startIndex, offsetBy: 0)
        return String(s[range])
    }
    private var hiString: String {
        let s = GuardEscapedView.taihiStrings
        let range = s.index(s.endIndex, offsetBy: -1)
        return String(s[range])
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let bounds = self.bounds
        NSColor(calibratedWhite: 0.9, alpha: 0.8).setFill()
        NSBezierPath(rect: bounds).fill()
        
        switch controlSize {
        case .regular: drawTaihi(in: bounds)
        case .small, .mini: drawSmallTaihi(in: bounds)
        }
    }
    
    private func drawTaihi(in bounds: NSRect) {
        let rotate = NSAffineTransform()
        rotate.translateX(by: 0.0, yBy: 65.0)
        rotate.rotate(byDegrees: -27)
        rotate.concat()
        
        let width = 50
        let height = 100
        let x = Int((bounds.width - CGFloat(width)) * 0.5)
        let y = Int((bounds.height - CGFloat(height)) * 0.5)
        let rect = NSRect(x: x, y: y, width: width, height: height)
        let path = NSBezierPath(rect: rect)
        NSColor.white.setFill()
        NSColor.black.setStroke()
        path.fill()
        path.stroke()
        
        let borderRect = rect.insetBy(dx: 3, dy: 3)
        let borderPath = NSBezierPath(rect: borderRect)
        borderPath.lineWidth = 2.0
        borderPath.stroke()
        
        let fontSize = NSFont.boldSystemFont(ofSize: CGFloat(width - 10))
        let attributes = [ NSForegroundColorAttributeName: NSColor.lightGray,
                           NSFontAttributeName: fontSize ]
        let tai = NSAttributedString(string: taiString, attributes: attributes)
        let hi = NSAttributedString(string: hiString, attributes: attributes)
        
        var stringRect = borderRect.insetBy(dx: 2, dy: 2)
        stringRect.origin.y += 4
        stringRect.origin.x += 1.5
        stringRect.size.height -= 2
        tai.draw(in: stringRect)
        stringRect.size.height *= 0.5
        hi.draw(in: stringRect)
    }
    private func drawSmallTaihi(in bounds: NSRect) {
        let width = 100
        let height = 50
        let x = Int((bounds.width - CGFloat(width)) * 0.5)
        let y = Int((bounds.height - CGFloat(height)) * 0.5)
        let rect = NSRect(x: x, y: y, width: width, height: height)
        let path = NSBezierPath(rect: rect)
        NSColor.white.setFill()
        NSColor.black.setStroke()
        path.fill()
        path.stroke()
        
        let borderRect = rect.insetBy(dx: 3, dy: 3)
        let borderPath = NSBezierPath(rect: borderRect)
        borderPath.lineWidth = 2.0
        borderPath.stroke()
        
        let fontSize = NSFont.boldSystemFont(ofSize: CGFloat(height - 14))
        let attributes = [ NSForegroundColorAttributeName: NSColor.lightGray,
                           NSFontAttributeName: fontSize ]
        let tai = NSAttributedString(string: taiString, attributes: attributes)
        let hi = NSAttributedString(string: hiString, attributes: attributes)
        
        var stringRect = borderRect.insetBy(dx: 2, dy: 2)
        stringRect.origin.y += 5
        stringRect.origin.x += 5
        stringRect.size.height -= 2
        tai.draw(in: stringRect)
        stringRect.origin.x += stringRect.width * 0.5 + 1
        hi.draw(in: stringRect)
    }
}
