//
//  DamageView.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/01.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

enum DamageType: Int {
    
    case none = 0
    case slightly
    case modest
    case badly
}

final class DamageView: NSView {
    
    @objc dynamic var damageType: Int = 0 {
        
        willSet {
            
            guard let v = DamageType(rawValue: newValue) else {
                
                Logger.shared.log("Can not set damageType")
                
                return
            }
            
            if innerDamageType != v {
                
                needsDisplay = true
            }
            
            innerDamageType = v
        }
    }
    
    var controlSize: NSControl.ControlSize = .regular
    private var innerDamageType: DamageType = .none
    private var color: NSColor? {
        
        switch innerDamageType {
            
        case .none: return nil
            
        case .slightly: return ColorSetManager.current[.damageViewInnerSlightly]
            
        case .modest: return ColorSetManager.current[.damageViewInnerModest]
            
        case .badly: return ColorSetManager.current[.damageViewInnerBadly]
            
        }
    }
    
    private var borderColor: NSColor? {
                
        switch innerDamageType {
            
        case .none: return nil
            
        case .slightly: return ColorSetManager.current[.damageViewBoarderSlightly]
            
        case .modest: return ColorSetManager.current[.damageViewBoarderModest]
            
        case .badly: return ColorSetManager.current[.damageViewBoarderBadly]
            
        }
    }
    
    private var path: Polygon? {
        
        switch controlSize {
            
        case .regular:
            
            return pathForRegular
            
        case .small, .mini:
            
            return pathForSmall
            
        }
    }
    
    private var pathForRegular: Polygon? {
        
        let height = bounds.height
        
        switch innerDamageType {
            
        case .none:
            
            return nil
            
        case .slightly:
            
            return Polygon()
                .move(to: NSPoint(x: 35.0, y: height - 2.0))
                .line(to: NSPoint(x: 0.0, y: height - 2.0))
                .line(to: NSPoint(x: 0.0, y: height - 35.0))
                .close()
            
        case .modest:
            
            return Polygon()
                .move(to: NSPoint(x: 50.0, y: height - 2.0))
                .line(to: NSPoint(x: 25.0, y: height - 2.0))
                .line(to: NSPoint(x: 0.0, y: height - 25.0))
                .line(to: NSPoint(x: 0.0, y: height - 50.0))
                .close()
            
        case .badly:
            
            return Polygon()
                .move(to: NSPoint(x: 60.0, y: height - 2.0))
                .line(to: NSPoint(x: 53.0, y: height - 2.0))
                .line(to: NSPoint(x: 0.0, y: height - 53.0))
                .line(to: NSPoint(x: 0.0, y: height - 60.0))
                .close()
                .move(to: NSPoint(x: 47.0, y: height - 2.0))
                .line(to: NSPoint(x: 23.0, y: height - 2.0))
                .line(to: NSPoint(x: 0.0, y: height - 23.0))
                .line(to: NSPoint(x: 0.0, y: height - 47.0))
                .close()
            
        }
    }
    
    private var pathForSmall: Polygon? {
        
        let height = bounds.height
        
        switch innerDamageType {
            
        case .none:
            
            return nil
            
        case .slightly:
            
            return Polygon()
                .move(to: NSPoint(x: 35.0, y: height - 2.0))
                .line(to: NSPoint(x: 0.0, y: height - 2.0))
                .line(to: NSPoint(x: 0.0, y: height - 35.0))
                .close()
            
        case .modest:
            
            return Polygon()
                .move(to: NSPoint(x: 50.0, y: height - 2.0))
                .line(to: NSPoint(x: 25.0, y: height - 2.0))
                .line(to: NSPoint(x: 0.0, y: height - 25.0))
                .line(to: NSPoint(x: 0.0, y: height - 50.0))
                .close()
            
        case .badly:
            
            return Polygon()
                .move(to: NSPoint(x: 55.0, y: height - 2.0))
                .line(to: NSPoint(x: 48.0, y: height - 2.0))
                .line(to: NSPoint(x: 0.0, y: height - 48.0))
                .line(to: NSPoint(x: 0.0, y: height - 55.0))
                .close()
                .move(to: NSPoint(x: 42.0, y: height - 2.0))
                .line(to: NSPoint(x: 20.0, y: height - 2.0))
                .line(to: NSPoint(x: 0.0, y: height - 20.0))
                .line(to: NSPoint(x: 0.0, y: height - 42.0))
                .close()
            
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)
        
        color?.setFill()
        borderColor?.setStroke()
        path?.fill()
        path?.stroke()
    }
}
