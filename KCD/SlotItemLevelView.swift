//
//  SlotItemLevelView.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class SlotItemLevelView: NSTextField {
    
    private static var sLevelMaskImage: CGImage?
    private static var sAirLevelMaskImage: CGImage?
    private static var sCharacterProtrudeMaskImageMaskImage: CGImage?
    
    private let offset: CGFloat = 28
    private let padding: CGFloat = 4
    private let slideOffset: CGFloat = 3.5
    private let anglePoint: CGFloat = 4.0
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect)
        
        bind(NSBindingName(#keyPath(slotItemLevel)), to: slotItemController, withKeyPath: "selection.level", options: nil)
        bind(NSBindingName(#keyPath(slotItemAlv)), to: slotItemController, withKeyPath: "selection.alv", options: nil)
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        bind(NSBindingName(#keyPath(slotItemLevel)), to: slotItemController, withKeyPath: "selection.level", options: nil)
        bind(NSBindingName(#keyPath(slotItemAlv)), to: slotItemController, withKeyPath: "selection.alv", options: nil)
    }
    
    deinit {
        
        unbind(NSBindingName(#keyPath(slotItemLevel)))
        unbind(NSBindingName(#keyPath(slotItemAlv)))
    }
    
    // MARK: - Variable
    @objc dynamic var slotItemController = NSObjectController()
    @objc dynamic var slotItemLevel: NSNumber? {
        
        didSet { needsDisplay = true }
    }
    
    @objc dynamic var slotItemAlv: NSNumber? {
        
        didSet { needsDisplay = true }
    }
    
    
    @objc var slotItemID: NSNumber? {
        didSet {
            slotItemController.content = nil
            
            guard let itemId = slotItemID as? Int else { return }
            
            slotItemController.content = ServerDataStore.default.slotItem(by: itemId)
            needsDisplay = true
        }
    }
    
    private var maskImage: CGImage? {
        
        if let alv = slotItemAlv as? Int, alv != 0 { return airLevelMaskImage }
        if let lv = slotItemLevel as? Int, lv != 0 { return levelMaskImage }
        
        if isCharacterProtrude() { return characterProtrudeMaskImage }
        
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
    private var characterProtrudeMaskImage: CGImage {
        
        if let r = SlotItemLevelView.sCharacterProtrudeMaskImageMaskImage { return r }
        SlotItemLevelView.sCharacterProtrudeMaskImageMaskImage = maskImage(middle1: 0.9, middle2: 1.0)
        
        return SlotItemLevelView.sCharacterProtrudeMaskImageMaskImage!
    }
    
    private var levelOneBezierPath: NSBezierPath? {
        
        let width = bounds.width
        let height = bounds.height
        let path = multiline(lines: [
            (
                NSPoint(x: width - offset, y: 0),
                NSPoint(x: width - offset, y: height)
            )
            ])
        path.lineWidth = 1.0
        
        return path
    }
    
    private var levelTwoBezierPath: NSBezierPath? {
        
        let width = bounds.width
        let height = bounds.height
        let path = multiline(lines:
            [
                (
                    NSPoint(x: width - offset, y: 0),
                    NSPoint(x: width - offset, y: height)
                ),
                (
                    NSPoint(x: width - offset - padding, y: 0),
                    NSPoint(x: width - offset - padding, y: height)
                )
            ])
        path.lineWidth = 1.0
        
        return path
    }
    
    private var levelThreeBezierPath: NSBezierPath? {
        
        let width = bounds.width
        let height = bounds.height
        let path = multiline(lines:
            [
                (
                    NSPoint(x: width - offset, y: 0),
                    NSPoint(x: width - offset, y: height)
                ),
                (
                    NSPoint(x: width - offset - padding, y: 0),
                    NSPoint(x: width - offset - padding, y: height)
                ),
                (
                    NSPoint(x: width - offset - padding * 2, y: 0),
                    NSPoint(x: width - offset - padding * 2, y: height)
                )
            ])
        path.lineWidth = 1.0
        
        return path
    }
    
    private var levelFourBezierPath: NSBezierPath? {
        
        let width = bounds.width
        let height = bounds.height
        let path = multiline(lines:
            [
                (
                    NSPoint(x: width - offset - slideOffset, y: 0),
                    NSPoint(x: width - offset, y: height)
                )
            ])
        path.lineWidth = 2.0
        
        return path
    }
    
    private var levelFiveBezierPath: NSBezierPath? {
        
        let width = bounds.width
        let height = bounds.height
        let path = multiline(lines:
            [
                (
                    NSPoint(x: width - offset - slideOffset, y: 0),
                    NSPoint(x: width - offset, y: height)
                ),
                (
                    NSPoint(x: width - offset - padding - slideOffset, y: 0),
                    NSPoint(x: width - offset - padding, y: height)
                )
            ])
        path.lineWidth = 2.0
        
        return path
    }
    
    private var levelSixBezierPath: NSBezierPath? {
        
        let width = bounds.width
        let height = bounds.height
        let path = multiline(lines:
            [
                (
                    NSPoint(x: width - offset - slideOffset, y: 0),
                    NSPoint(x: width - offset, y: height)
                ),
                (
                    NSPoint(x: width - offset - padding - slideOffset, y: 0),
                    NSPoint(x: width - offset - padding, y: height)
                ),
                (
                    NSPoint(x: width - offset - padding * 2 - slideOffset, y: 0),
                    NSPoint(x: width - offset - padding * 2, y: height)
                )
            ])
        path.lineWidth = 2.0
        
        return path
    }
    
    private var levelSevenBezierPath: NSBezierPath? {
        
        let width = bounds.width
        let height = bounds.height
        let path = polyline(points:
            [
                NSPoint(x: width - offset - slideOffset, y: 0),
                NSPoint(x: width - offset, y: height * 0.5),
                NSPoint(x: width - offset - anglePoint, y: height)
            ])
        polyline(points:
            [
                NSPoint(x: width - offset - padding - slideOffset, y: 0),
                NSPoint(x: width - offset - padding, y: height * 0.5),
                NSPoint(x: width - offset - padding - anglePoint, y: height)
            ])
            .map { path?.append($0) }
        path?.lineWidth = 2.0
        
        return path
    }
    
    private var levelFont: NSFont {
        
        return NSFont.monospacedDigitSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
    }
    
    private var levelColor: NSColor {
        
        return #colorLiteral(red: 0.135, green: 0.522, blue: 0.619, alpha: 1)
    }
    
    // MARK: - Function
    override func draw(_ dirtyRect: NSRect) {
        
        guard let context = NSGraphicsContext.current?.cgContext else { fatalError("Con not get current CGContext") }
        
        context.saveGState()
        maskImage.map { context.clip(to: bounds, mask: $0) }
        
        super.draw(dirtyRect)
        
        context.restoreGState()
        
        drawLevel()
        drawAirLevel()
    }
    
    private func bezierPathForALevel(level: Int) -> NSBezierPath? {
        
        switch level {
        case 1: return levelOneBezierPath
        case 2: return levelTwoBezierPath
        case 3: return levelThreeBezierPath
        case 4: return levelFourBezierPath
        case 5: return levelFiveBezierPath
        case 6: return levelSixBezierPath
        case 7: return levelSevenBezierPath
        default: return nil
        }
    }
    
    private func colorForALevel(level: Int) -> NSColor? {
        
        switch level {
        case 1, 2, 3: return #colorLiteral(red: 0.257, green: 0.523, blue: 0.643, alpha: 1)
        case 4, 5, 6, 7: return #colorLiteral(red: 0.784, green: 0.549, blue: 0.000, alpha: 1)
        default: return nil
        }
    }
    
    private func shadowForALevel(level: Int) -> NSShadow? {
        
        switch level {
        case 1, 2, 3:
            let shadow = NSShadow()
            shadow.shadowColor = #colorLiteral(red: 0.095, green: 0.364, blue: 0.917, alpha: 1)
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
        
        guard let lv = slotItemLevel as? Int, lv != 0 else { return }
        
        let string = (lv == 10 ? "max" : "★+\(lv)")
        let attr: [NSAttributedStringKey: Any] = [.font: levelFont,
                                                  .foregroundColor: levelColor]
        let attributedString = NSAttributedString(string: string, attributes: attr)
        let boundingRect = attributedString.boundingRect(with: bounds.size)
        var rect = bounds
        rect.origin.x = rect.width - boundingRect.width - 1.0
        rect.origin.y = 0
        
        attributedString.draw(in: rect)
    }
}
