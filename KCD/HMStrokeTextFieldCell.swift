//
//  HMStrokeTextFieldCell.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/28.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMStrokeTextFieldCell: NSTextFieldCell
{
	let borderWidth: CGFloat = 2.0
	let layoutManager: NSLayoutManager = NSLayoutManager()
	lazy var textContainer: NSTextContainer = {
		let aTextContainer = NSTextContainer()
		self.layoutManager.addTextContainer(aTextContainer)
		return aTextContainer
	}()
	
	override func drawInteriorWithFrame(cellFrame: NSRect, inView controlView: NSView) {
		let attribute = attributedStringValue.attributesAtIndex(0, effectiveRange: nil)
		let forgroundColor = attribute[NSForegroundColorAttributeName] as? NSColor
		if forgroundColor == nil {
			return
		}
		if forgroundColor == NSColor.controlTextColor() {
			super.drawInteriorWithFrame(cellFrame, inView: controlView)
			return
		}
		
		let textStorage = NSTextStorage(string: attributedStringValue.string, attributes: attribute)
		textStorage.addLayoutManager(layoutManager)
		
		let range: NSRange = layoutManager.glyphRangeForTextContainer(textContainer)
		var glyph = [NSGlyph](count: range.length + 1, repeatedValue:0)
		let glyphLength = layoutManager.getGlyphs(&glyph, range: range)
		
		let font = attribute[NSFontAttributeName] as NSFont
		var point = NSPoint(x: borderWidth, y: -font.descender)
		if controlView.flipped {
			point.y -= controlView.frame.size.height
		}
		
		let path = NSBezierPath()
		path.moveToPoint(point)
		path.appendBezierPathWithGlyphs(&glyph, count: glyphLength, inFont: font)
		path.lineWidth = borderWidth
		path.lineJoinStyle = .RoundLineJoinStyle
		if controlView.flipped {
			let affineTransform = NSAffineTransform()
			affineTransform.scaleXBy(1, yBy: -1)
			path.transformUsingAffineTransform(affineTransform)
		}
		
		NSColor.blackColor().set()
		path.stroke()
		
		forgroundColor!.set()
		path.fill()
	}
}
