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
        
        didSet { needsDisplayInMainThread() }
    }
    
    @objc dynamic var slotItemAlv: NSNumber? {
        
        didSet { needsDisplayInMainThread() }
    }
    
    @objc var slotItemID: NSNumber? {
        
        didSet {
            
            slotItemController.content = nil
            
            guard let itemId = slotItemID as? Int else {
                
                return
            }
            
            slotItemController.content = ServerDataStore.default.slotItem(by: itemId)
            needsDisplayInMainThread()
        }
    }
    
    private var maskImage: CGImage? {
        
        if let alv = slotItemAlv as? Int, alv != 0 {
            
            return airLevelMaskImage
        }
        if let lv = slotItemLevel as? Int, lv != 0 {
            
            return levelMaskImage
        }
        
        if isCharacterProtrude() {
            
            return characterProtrudeMaskImage
        }
        
        return nil
    }
    
    private var levelMaskImage: CGImage {
        
        if let r = SlotItemLevelView.sLevelMaskImage {
            
            return r
        }
        SlotItemLevelView.sLevelMaskImage = maskImage(middle1: 0.75, middle2: 0.85)
        
        return SlotItemLevelView.sLevelMaskImage!
    }
    
    private var airLevelMaskImage: CGImage {
        
        if let r = SlotItemLevelView.sAirLevelMaskImage {
            
            return r
        }
        SlotItemLevelView.sAirLevelMaskImage = maskImage(middle1: 0.65, middle2: 0.75)
        
        return SlotItemLevelView.sAirLevelMaskImage!
    }
    private var characterProtrudeMaskImage: CGImage {
        
        if let r = SlotItemLevelView.sCharacterProtrudeMaskImageMaskImage {
            
            return r
        }
        SlotItemLevelView.sCharacterProtrudeMaskImageMaskImage = maskImage(middle1: 0.9, middle2: 1.0)
        
        return SlotItemLevelView.sCharacterProtrudeMaskImageMaskImage!
    }
    
    private var levelOneBezierPath: Polygon {
        
        let width = bounds.width
        let height = bounds.height
        
        return Polygon(lineWidth: 1.0)
            .move(to: NSPoint(x: width - offset, y: 0))
            .line(to: NSPoint(x: width - offset, y: height))
    }
    
    private var levelTwoBezierPath: Polygon {
        
        let width = bounds.width
        let height = bounds.height
        
        return Polygon(lineWidth: 1.0)
            .move(to: NSPoint(x: width - offset, y: 0))
            .line(to: NSPoint(x: width - offset, y: height))
            .move(to: NSPoint(x: width - offset - padding, y: 0))
            .line(to: NSPoint(x: width - offset - padding, y: height))
    }
    
    private var levelThreeBezierPath: Polygon {
        
        let width = bounds.width
        let height = bounds.height
        
        return Polygon(lineWidth: 1.0)
            .move(to: NSPoint(x: width - offset, y: 0))
            .line(to: NSPoint(x: width - offset, y: height))
            .move(to: NSPoint(x: width - offset - padding, y: 0))
            .line(to: NSPoint(x: width - offset - padding, y: height))
            .move(to: NSPoint(x: width - offset - padding * 2, y: 0))
            .line(to: NSPoint(x: width - offset - padding * 2, y: height))
    }
    
    private var levelFourBezierPath: Polygon {
        
        let width = bounds.width
        let height = bounds.height
        
        return Polygon(lineWidth: 2.0)
            .move(to: NSPoint(x: width - offset - slideOffset, y: 0))
            .line(to: NSPoint(x: width - offset, y: height))
    }
    
    private var levelFiveBezierPath: Polygon {
        
        let width = bounds.width
        let height = bounds.height
        
        return Polygon(lineWidth: 2.0)
            .move(to: NSPoint(x: width - offset - slideOffset, y: 0))
            .line(to: NSPoint(x: width - offset, y: height))
            .move(to: NSPoint(x: width - offset - padding - slideOffset, y: 0))
            .line(to: NSPoint(x: width - offset - padding, y: height))
    }
    
    private var levelSixBezierPath: Polygon {
        
        let width = bounds.width
        let height = bounds.height
        
        return Polygon(lineWidth: 2.0)
            .move(to: NSPoint(x: width - offset - slideOffset, y: 0))
            .line(to: NSPoint(x: width - offset, y: height))
            .move(to: NSPoint(x: width - offset - padding - slideOffset, y: 0))
            .line(to: NSPoint(x: width - offset - padding, y: height))
            .move(to: NSPoint(x: width - offset - padding * 2 - slideOffset, y: 0))
            .line(to: NSPoint(x: width - offset - padding * 2, y: height))
    }
    
    private var levelSevenBezierPath: Polygon {
        
        let width = bounds.width
        let height = bounds.height
        
        return Polygon(lineWidth: 2.0)
            .move(to: NSPoint(x: width - offset - slideOffset, y: 0))
            .line(to: NSPoint(x: width - offset, y: height * 0.5))
            .line(to: NSPoint(x: width - offset - anglePoint, y: height))
            .move(to: NSPoint(x: width - offset - padding - slideOffset, y: 0))
            .line(to: NSPoint(x: width - offset - padding, y: height * 0.5))
            .line(to: NSPoint(x: width - offset - padding - anglePoint, y: height))
    }
    
    private var levelFont: NSFont {
        
        return .monospacedDigitSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
    }
    
    private var levelColor: NSColor {
        
        return ColorSetManager.current[.slotItemLevelViewLevel]
        
        
    }
    
    // MARK: - Function
    override func draw(_ dirtyRect: NSRect) {
        
        guard let context = NSGraphicsContext.current?.cgContext else {
            
            fatalError("Con not get current CGContext")
        }
        
        context.saveGState()
        maskImage.map { context.clip(to: bounds, mask: $0) }
        
        super.draw(dirtyRect)
        
        context.restoreGState()
        
        drawLevel()
        drawAirLevel()
    }
    
    private func bezierPathForALevel(level: Int) -> Polygon? {
        
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
            
        case 1, 2, 3: return ColorSetManager.current[.slotItemLevelViewLowAirLevel]
            
        case 4, 5, 6, 7: return ColorSetManager.current[.slotItemLevelViewHighAirLevel]
            
        default: return nil
            
        }
    }
    
    private func shadowForALevel(level: Int) -> NSShadow? {
        
        switch level {
            
        case 1, 2, 3:
            let shadow = NSShadow()
            shadow.shadowColor = ColorSetManager.current[.slotItemLevelViewLowAirLevelShadow]
            shadow.shadowBlurRadius = 4.0
            
            return shadow
            
        case 4, 5, 6, 7:
            let shadow = NSShadow()
            shadow.shadowColor = ColorSetManager.current[.slotItemLevelViewHighAirLevelShadow]
            shadow.shadowBlurRadius = 3.0
            
            return shadow
            
        default:
            
            return nil
        }
    }
    
    private func drawAirLevel() {
        
        guard let alv = slotItemAlv as? Int else {
            
            return
        }
        
        colorForALevel(level: alv)?.set()
        shadowForALevel(level: alv)?.set()
        bezierPathForALevel(level: alv)?.stroke()
    }
    
    private func drawLevel() {
        
        guard let lv = slotItemLevel as? Int, lv != 0 else {
            
            return
        }
        
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
