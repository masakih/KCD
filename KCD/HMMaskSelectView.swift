//
//  HMMaskSelectView.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/30.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMMaskSelectView: NSView
{
	override init(frame: NSRect) {
		super.init(frame: frame)
		masks = makeMask(frame: frame)
	}
	required init?(coder: NSCoder) {
	    super.init(coder: coder)
		masks = makeMask(frame: frame)
	}
	
	let masks: [HMMaskInformation]!
	
	private func makeMask(frame frameRect: NSRect) -> [HMMaskInformation] {
		let originalSize: NSSize = NSSize(width: 800, height: 480)
		
		var masks: [HMMaskInformation] = []
		let widthRatio = frameRect.size.width / originalSize.width
		let heightRatio = frameRect.size.height / originalSize.height
		
		let maskRects: [NSRect] = [
			NSRect(x: 113, y: 455, width: 100, height: 18),
			NSRect(x: 203, y: 330, width: 200, height: 25),
			NSRect(x: 95, y: 378, width: 100, height: 18),
			NSRect(x: 60, y: 378, width: 100, height: 18)
		]
		
		for i in 0..<maskRects.count {
			let info = HMMaskInformation()
			info.maskRect = NSRect(
				x: maskRects[i].origin.x * widthRatio,
				y: maskRects[i].origin.y * heightRatio,
				width: maskRects[i].size.width * widthRatio,
				height: maskRects[i].size.height * heightRatio)
			if i == 3 {
				info.borderColor = NSColor(calibratedRed: 0.00, green: 0.011, blue: 1.000, alpha: 1.000)
			} else {
				info.borderColor = NSColor.redColor()
			}
			masks += [info]
		}
		return masks
	}
	
    override func drawRect(dirtyRect: NSRect) {
		let context = NSGraphicsContext.currentContext()
		context?.saveGraphicsState()
		context?.shouldAntialias = false
		
		let dashSeed:[CGFloat] = [3.0, 3.0]
		for info in masks {
			let path = NSBezierPath(rect: info.maskRect)
			if info.enable {
				info.maskColor.set()
				path.fill()
			}
			path.setLineDash(dashSeed, count: dashSeed.count, phase: 0)
			info.borderColor?.set()
			path.stroke()
			path.setLineDash(dashSeed, count: dashSeed.count, phase: 3.0)
			NSColor.lightGrayColor().set()
			path.stroke()
		}
		context?.restoreGraphicsState()
    }
	
	override func mouseUp(theEvent: NSEvent) {
		var mouse = theEvent.locationInWindow
		mouse = convertPoint(mouse, fromView: nil)
		for info in masks.reverse() {
			if NSMouseInRect(mouse, info.maskRect, flipped) {
				info.enable = !info.enable
				setNeedsDisplayInRect(NSInsetRect(info.maskRect, -5, -5))
				break
			}
		}
	}
	
	@IBAction func disableAllMasks(sender: AnyObject?) {
		for info in masks {
			info.enable = false
		}
		needsDisplay = true
	}
}
