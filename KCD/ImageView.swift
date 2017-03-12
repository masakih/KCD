//
//  ImageView.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class ImageView: NSView {
    var images: [NSImage] = [] {
        didSet { needsDisplay = true }
    }
    var imageRect: NSRect {
        if images.isEmpty { return .zero }
        let bounds = self.bounds
        let offset = NSWidth(bounds) * 0.1 / 2 / 3
        let border = offset * 3
        let rect = NSInsetRect(bounds, border, border)
        let size = images[0].size
        let ratioX = NSHeight(rect) / size.height
        let ratioY = NSWidth(rect) / size.width
        let ratio = ratioX > ratioY ? ratioY : ratioX
        let drawSize = NSSize(width: size.width * ratio, height: size.height * ratio)
        return NSRect(
            x: NSMinX(rect) + (NSWidth(rect) - drawSize.width) / 2,
            y: NSMinY(rect) + (NSHeight(rect) - drawSize.height) / 2,
            width: drawSize.width,
            height: drawSize.height)
    }
    private var internalImageShadow: NSShadow?
    private var imageShadow: NSShadow {
        if let s = internalImageShadow { return s }
        let s = NSShadow()
        s.shadowOffset = NSSize(width: 2, height: -2)
        s.shadowBlurRadius = 4
        s.shadowColor = NSColor.darkGray
        internalImageShadow = s
        return s
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let bounds = self.bounds
        NSColor.controlBackgroundColor.set()
        NSBezierPath.stroke(bounds)
        
        NSColor.black.set()
        NSBezierPath.setDefaultLineWidth(1.0)
        NSBezierPath.stroke(bounds)
        
        NSBezierPath.clip(NSInsetRect(bounds, 1, 1))
        
        imageShadow.set()
        
        let count = images.count
        
        let alphaFactor = 0.7
        var alpha = pow(alphaFactor, Double(count - 1))
        
        let offset = NSWidth(bounds) * 0.1 / 2 / 3
        let border = offset * 3
        let rect = NSInsetRect(bounds, border, border)
        
        images
            .enumerated()
            .reversed()
            .forEach {
                let offsetRect = NSOffsetRect(rect, offset * CGFloat($0.offset), offset * CGFloat($0.offset))
                let drawRect = imageRect(with: offsetRect, imageSize: $0.element.size)
                $0.element.draw(in: drawRect, from: .zero, operation: NSCompositeSourceOver, fraction: CGFloat(alpha))
                alpha /= alphaFactor
        }
    }

    private func imageRect(with rect: NSRect, imageSize: NSSize) -> NSRect {
        let ratioX = NSHeight(rect) / imageSize.height
        let ratioY = NSWidth(rect) / imageSize.width
        let ratio = ratioX > ratioY ? ratioY : ratioX
        let drawSize = NSSize(width: imageSize.width * ratio,
                              height: imageSize.height * ratio)
        return NSRect(
            x: NSMinX(rect) + (NSWidth(rect) - drawSize.width) / 2,
            y: NSMinY(rect) + (NSHeight(rect) - drawSize.height) / 2,
            width: drawSize.width,
            height: drawSize.height)
    }
}
