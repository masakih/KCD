//
//  SlotItemLevelView.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class SlotItemLevelView: NSTextField {
    private static var sLevelMaskImage: CGImage?
    private static var sAirLevelMaskImage: CGImage?
    
    private let offset: CGFloat = 28
    private let padding: CGFloat = 4
    private let slideOffset: CGFloat = 3.5
    private let anglePoint: CGFloat = 4.0
    
    override init(frame frameRect: NSRect) {
        slotItemController = NSObjectController()
        super.init(frame: frameRect)
        self.bind("slotItemLevel", to: slotItemController, withKeyPath: "selection.level", options: nil)
        self.bind("slotItemAlv", to: slotItemController, withKeyPath: "selection.alv", options: nil)
    }
    required init?(coder: NSCoder) {
        slotItemController = NSObjectController()
        super.init(coder: coder)
        self.bind("slotItemLevel", to: slotItemController, withKeyPath: "selection.level", options: nil)
        self.bind("slotItemAlv", to: slotItemController, withKeyPath: "selection.alv", options: nil)
    }
    deinit {
        self.unbind("slotItemLevel")
        self.unbind("slotItemAlv")
    }
    
    // MARK: - Variable
    dynamic var slotItemController: NSObjectController
    dynamic var slotItemLevel: NSNumber? {
        didSet { needsDisplay = true }
    }
    dynamic var slotItemAlv: NSNumber? {
        didSet { needsDisplay = true }
    }
    var slotItemID: NSNumber? {
        didSet {
            slotItemController.content = nil
            guard let itemId = slotItemID as? Int,
                let slotItem = ServerDataStore.default.slotItem(byId: itemId)
                else { return }
            slotItemController.content = slotItem
            needsDisplay = true
        }
    }
    private var maskImage: CGImage? {
        if let alv = slotItemAlv as? Int,
            alv != 0 { return airLevelMaskImage }
        if let lv = slotItemLevel as? Int,
            lv != 0 { return levelMaskImage }
        return nil
    }
    private var levelMaskImage: CGImage {
        if let r = SlotItemLevelView.sLevelMaskImage { return r }
        
        SlotItemLevelView.sLevelMaskImage = maskImage(middle1: 0.75, middle2: 0.85)
        return SlotItemLevelView.sLevelMaskImage!
    }
    private var airLevelMaskImage: CGImage {
        if let r = SlotItemLevelView.sAirLevelMaskImage { return r }
        
        SlotItemLevelView.sAirLevelMaskImage = maskImage(middle1: 0.65, middle2: 0.75)
        return SlotItemLevelView.sAirLevelMaskImage!
    }
    private var levelOneBezierPath: NSBezierPath? {
        let bounds = self.bounds
        let width = bounds.width
        let height = bounds.height
        let path = multiline {
            [(NSPoint(x: width - offset, y: 0), NSPoint(x: width - offset, y: height))]
        }
        path?.lineWidth = 1.0
        return path
    }
    private var levelTwoBezierPath: NSBezierPath? {
        let bounds = self.bounds
        let width = bounds.width
        let height = bounds.height
        let path = multiline {
            [(NSPoint, NSPoint)]()
                .appended { (NSPoint(x: width - offset, y: 0), NSPoint(x: width - offset, y: height)) }
                .appended { (NSPoint(x: width - offset - padding, y: 0), NSPoint(x: width - offset - padding, y: height)) }
        }
        path?.lineWidth = 1.0
        return path
    }
    private var levelThreeBezierPath: NSBezierPath? {
        let bounds = self.bounds
        let width = bounds.width
        let height = bounds.height
        let path = multiline {
            [(NSPoint, NSPoint)]()
                .appended { (NSPoint(x: width - offset, y: 0), NSPoint(x: width - offset, y: height)) }
                .appended { (NSPoint(x: width - offset - padding, y: 0), NSPoint(x: width - offset - padding, y: height)) }
                .appended { (NSPoint(x: width - offset - padding * 2, y: 0), NSPoint(x: width - offset - padding * 2, y: height)) }
        }
        path?.lineWidth = 1.0
        return path
    }
    private var levelFourBezierPath: NSBezierPath? {
        let bounds = self.bounds
        let width = bounds.width
        let height = bounds.height
        let path = multiline {
            [(NSPoint, NSPoint)]()
                .appended { (NSPoint(x: width - offset - slideOffset, y: 0), NSPoint(x: width - offset, y: height)) }
        }
        path?.lineWidth = 2.0
        return path
    }
    private var levelFiveBezierPath: NSBezierPath? {
        let bounds = self.bounds
        let width = bounds.width
        let height = bounds.height
        let path = multiline {
            [(NSPoint, NSPoint)]()
                .appended { (NSPoint(x: width - offset - slideOffset, y: 0), NSPoint(x: width - offset, y: height)) }
                .appended { (NSPoint(x: width - offset - padding - slideOffset, y: 0), NSPoint(x: width - offset - padding, y: height)) }
        }
        path?.lineWidth = 2.0
        
        return path
    }
    private var levelSixBezierPath: NSBezierPath? {
        let bounds = self.bounds
        let width = bounds.width
        let height = bounds.height
        let path = multiline {
            [(NSPoint, NSPoint)]()
                .appended { (NSPoint(x: width - offset - slideOffset, y: 0), NSPoint(x: width - offset, y: height)) }
                .appended { (NSPoint(x: width - offset - padding - slideOffset, y: 0), NSPoint(x: width - offset - padding, y: height)) }
                .appended { (NSPoint(x: width - offset - padding * 2 - slideOffset, y: 0), NSPoint(x: width - offset - padding * 2, y: height)) }
        }
        path?.lineWidth = 2.0
        return path
    }
    private var levelSevenBezierPath: NSBezierPath? {
        let bounds = self.bounds
        let width = bounds.width
        let height = bounds.height
        let path = polyline {
            [NSPoint]()
                .appended { NSPoint(x: width - offset - slideOffset, y: 0) }
                .appended { NSPoint(x: width - offset, y: height * 0.5) }
                .appended { NSPoint(x: width - offset - anglePoint, y: height) }
        }
        polyline {
            [NSPoint]()
                .appended { NSPoint(x: width - offset - padding - slideOffset, y: 0) }
                .appended { NSPoint(x: width - offset - padding, y: height * 0.5) }
                .appended { NSPoint(x: width - offset - padding - anglePoint, y: height) }
            }
            .map { path?.append($0) }
        path?.lineWidth = 2.0
        return path
    }
    private var levelFont: NSFont {
        let size = NSFont.smallSystemFontSize()
        return NSFont.monospacedDigitSystemFont(ofSize: size, weight: NSFontWeightRegular)
    }
    private var levelColor: NSColor {
        return NSColor(calibratedRed: 0.135, green: 0.522, blue: 0.619, alpha: 1.0)
    }
    
    // MARK: - Function
    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current()?.cgContext else {
            fatalError("Con not get current CGContext")
        }
        context.saveGState()
        if let mask = maskImage { context.clip(to: self.bounds, mask: mask) }
        super.draw(dirtyRect)
        context.restoreGState()
        
        drawLevel()
        drawAirLevel()
    }
    
    private func maskImage(middle1: CGFloat, middle2: CGFloat) -> CGImage {
        let bounds = self.bounds
        let colorspace = CGColorSpaceCreateDeviceGray()
        guard let maskContext = CGContext(
            data: nil, width: Int(bounds.width), height: Int(bounds.height),
            bitsPerComponent: 8, bytesPerRow: Int(bounds.width),
            space: colorspace, bitmapInfo: 0) else {
            fatalError("Can not create bitmap context")
        }
        let maskGraphicsContext = NSGraphicsContext(cgContext: maskContext, flipped: false)
        NSGraphicsContext.saveGraphicsState()
        defer { NSGraphicsContext.restoreGraphicsState() }
        NSGraphicsContext.setCurrent(maskGraphicsContext)
        
        let gradient = NSGradient(colorsAndLocations: (NSColor.white, 0.0),
                                  (NSColor.white, middle1),
                                  (NSColor.black, middle2),
                                  (NSColor.black, 1.0))
        gradient?.draw(in: bounds, angle: 0.0)
        guard let r = maskContext.makeImage() else {
            fatalError(" can not create image from context")
        }
        return r
    }
    
    private func bezierPathForALevel(level: Int) -> NSBezierPath? {
        switch level {
        case 1:
            return levelOneBezierPath
        case 2:
            return levelTwoBezierPath
        case 3:
            return levelThreeBezierPath
        case 4:
            return levelFourBezierPath
        case 5:
            return levelFiveBezierPath
        case 6:
            return levelSixBezierPath
        case 7:
            return levelSevenBezierPath
        default:
            return nil
        }
    }
    private func colorForALevel(level: Int) -> NSColor? {
        switch level {
        case 1, 2, 3:
            return NSColor(calibratedRed: 0.257, green: 0.523, blue: 0.643, alpha: 1.0)
        case 4, 5, 6, 7:
            return NSColor(calibratedRed: 0.784, green: 0.549, blue: 0.0, alpha: 1.0)
        default:
            return nil
        }
    }
    private func shadowForALevel(level: Int) -> NSShadow? {
        switch level {
        case 1, 2, 3:
            let shadow = NSShadow()
            shadow.shadowColor = NSColor(calibratedRed: 0.095, green: 0.364, blue: 0.917, alpha: 1.0)
            shadow.shadowBlurRadius = 4.0
            return shadow
        case 4, 5, 6, 7:
            let shadow = NSShadow()
            shadow.shadowColor = NSColor.yellow
            shadow.shadowBlurRadius = 3.0
            return shadow
        default:
            return nil
        }
    }
    private func drawAirLevel() {
        guard let alv = slotItemAlv as? Int else { return }
        colorForALevel(level: alv)?.set()
        shadowForALevel(level: alv)?.set()
        bezierPathForALevel(level: alv)?.stroke()
    }
    
    private func drawLevel() {
        guard let lv = slotItemLevel as? Int,
            lv != 0
            else { return }
        let string: String = lv == 10 ? "max" : "★+\(lv)"
        let attr: [String: Any] = [ NSFontAttributeName: levelFont,
                                     NSForegroundColorAttributeName: levelColor ]
        let attributedString = NSAttributedString(string: string, attributes: attr)
        let boundingRect = attributedString.boundingRect(with: self.bounds.size)
        var rect = self.bounds
        rect.origin.x = rect.width - boundingRect.width - 1.0
        rect.origin.y = 0
        
        attributedString.draw(in: rect)
    }
}
