//
//  StrokeTextFieldCell.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/01.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class StrokeTextFieldCell: NSTextFieldCell {
    private static let boarderWidth: CGFloat = 2.0
    
    private let layoutManager: NSLayoutManager
    private let textContainer: NSTextContainer
    
    required init(coder: NSCoder) {
        layoutManager = NSLayoutManager()
        textContainer = NSTextContainer()
        super.init(coder: coder)
        layoutManager.addTextContainer(textContainer)
    }
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        let attributedString = attributedStringValue
        if attributedString.string.hasSuffix("/") {
            super.drawInterior(withFrame: cellFrame, in: controlView)
            return
        }
        let attribute = attributedString.attributes(at: 0, effectiveRange: nil)
        guard let forgroundColor = attribute[NSForegroundColorAttributeName] as? NSColor else { return }
        if forgroundColor == NSColor.controlTextColor {
            super.drawInterior(withFrame: cellFrame, in: controlView)
            return
        }
        guard let font = attribute[NSFontAttributeName] as? NSFont else { return }
        
        let textStorage = NSTextStorage(string: attributedString.string, attributes: attribute)
        textStorage.addLayoutManager(layoutManager)
        let range = layoutManager.glyphRange(for: textContainer)
        let glyph = UnsafeMutablePointer<CGGlyph>.allocate(capacity: range.length)
        let glyphLength = layoutManager.getGlyphs(in: range,
                                                  glyphs: glyph,
                                                  properties: nil,
                                                  characterIndexes: nil,
                                                  bidiLevels: nil)
        var point = NSPoint(x: StrokeTextFieldCell.boarderWidth, y: 0)
        point.y -= font.descender
        if controlView.isFlipped {
            point.y -= controlView.frame.height
        }
        let nsGlyph = UnsafeMutablePointer<NSGlyph>.allocate(capacity: range.length)
        for i in 0...range.length {
            nsGlyph[i] = NSGlyph(glyph[i])
        }
        
        let path = NSBezierPath()
        path.move(to: point)
        path.appendGlyphs(nsGlyph, count: glyphLength, in: font)
        path.lineWidth = StrokeTextFieldCell.boarderWidth
        path.lineJoinStyle = .roundLineJoinStyle
        if controlView.isFlipped {
            var affineTransform = AffineTransform()
            affineTransform.scale(x: 1, y: -1)
            path.transform(using: affineTransform)
        }
        
        NSColor.black.set()
        path.stroke()
        forgroundColor.set()
        path.fill()
        
        textStorage.removeLayoutManager(layoutManager)
    }
}
