//
//  ColorSet.swift
//  KCD
//
//  Created by Hori,Masaki on 2018/06/24.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Cocoa

struct ColorName {
    
    let name: String
    
    init(name: String) {
        
        self.name = name
    }
    
    init(_ name: String) {
        
        self.name = name
    }
}

extension ColorName: Equatable {
    
    static func == (lhs: ColorName, rhs: ColorName) -> Bool {
        
        return lhs.name == rhs.name
    }
}

extension ColorName {
    
    // for DamageView
    static let damageViewInnerSlightly = ColorName("DamageView.inner.slightly")
    static let damageViewInnerModest = ColorName("DamageView.inner.modest")
    static let damageViewInnerBadly = ColorName("DamageView.inner.badly")
    static let damageViewBoarderSlightly = ColorName("DamageView.border.slightly")
    static let damageViewBoarderModest = ColorName("DamageView.border.modest")
    static let damageViewBoarderBadly = ColorName("DamageView.border.badly")
    
    // for AirPlanInfoView
    static let airPlanInforViewNormal = ColorName("AirPlanInfoView.normal")
    static let airPlanInforViewTired = ColorName("AirPlanInfoView.tired")
    static let airPlanInforViewBad = ColorName("AirPlanInfoView.bad")
    static let airPlanInforViewBoarderNormal = ColorName("AirPlanInfoView.boarder.normal")
    static let airPlanInforViewBoarderTired = ColorName("AirPlanInfoView.border.tired")
    static let airPlanInforViewBoarderBad = ColorName("AirPlanInfoView.boarder.bad")
    
    // for SuppliesCell
    static let suppliesCellGreen = ColorName("SuppliesCell.greenColor")
    static let suppliesCellYellow = ColorName("SuppliesCell.yellowColor")
    static let suppliesCellOrange = ColorName("SuppliesCell.orangeColor")
    static let suppliesCellRedColor = ColorName("SuppliesCell.redColor")
    static let suppliesCellBorder = ColorName("SuppliesCell.borderColor")
    static let suppliesCellBackground = ColorName("SuppliesCell.backgroundColor")
    
    // for SlotItemLevelView
    static let slotItemLevelViewLevel = ColorName("SlotItemLevelView.levelColor")
    static let slotItemLevelViewLowAirLevel = ColorName("SlotItemLevelView.airLevel.low")
    static let slotItemLevelViewHighAirLevel = ColorName("SlotItemLevelView.airLevel.high")
    static let slotItemLevelViewLowAirLevelShadow = ColorName("SlotItemLevelView.airLevel.low.shadow")
    static let slotItemLevelViewHighAirLevelShadow = ColorName("SlotItemLevelView.airLevel.high.shadow")
}

class ColorSet {
    
    static var current: ColorSet {
        
        if NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast {
            
            return HighContrastColorSet.shared
        }
        
        return ColorSet.shared
    }
    
    class var shared: ColorSet { return _shared }
    
    private static let _shared = ColorSet()
    
    subscript(named: ColorName) -> NSColor {
        
        switch named {
            
        case .damageViewInnerSlightly: return #colorLiteral(red: 1.000, green: 0.956, blue: 0.012, alpha: 0.5)
            
        case .damageViewInnerModest: return NSColor.orange.withAlphaComponent(0.5)
            
        case .damageViewInnerBadly: return NSColor.red.withAlphaComponent(0.5)
            
        case .damageViewBoarderSlightly: return NSColor.orange.withAlphaComponent(0.5)
            
        case .damageViewBoarderModest: return NSColor.orange.withAlphaComponent(0.9)
            
        case .damageViewBoarderBadly: return NSColor.red.withAlphaComponent(0.9)
            
            
        case .airPlanInforViewNormal: return .clear
            
        case .airPlanInforViewTired: return #colorLiteral(red: 1, green: 0.7233425379, blue: 0.1258574128, alpha: 0.8239436619)
            
        case .airPlanInforViewBad: return #colorLiteral(red: 0.7320367694, green: 0.07731548697, blue: 0.06799335033, alpha: 1)
            
        case .airPlanInforViewBoarderNormal: return .clear
            
        case .airPlanInforViewBoarderTired: return #colorLiteral(red: 0.458858192, green: 0.3335277438, blue: 0.07979661971, alpha: 1)
            
        case .airPlanInforViewBoarderBad: return #colorLiteral(red: 0.5462518334, green: 0.04599834234, blue: 0.04913448542, alpha: 1)
            
            
        case .suppliesCellGreen: return NSColor(calibratedWhite: 0.39, alpha: 1.0)
            
        case .suppliesCellYellow: return NSColor(calibratedWhite: 0.55, alpha: 1.0)
            
        case .suppliesCellOrange: return NSColor(calibratedWhite: 0.7, alpha: 1.0)
            
        case .suppliesCellRedColor: return NSColor(calibratedWhite: 0.79, alpha: 1.0)
            
        case .suppliesCellBorder: return .gridColor
            
        case .suppliesCellBackground: return .controlColor
            
            
        case .slotItemLevelViewLevel: return #colorLiteral(red: 0.135, green: 0.522, blue: 0.619, alpha: 1)
            
        case .slotItemLevelViewLowAirLevel: return #colorLiteral(red: 0.257, green: 0.523, blue: 0.643, alpha: 1)
            
        case .slotItemLevelViewHighAirLevel: return #colorLiteral(red: 0.784, green: 0.549, blue: 0.000, alpha: 1)
            
        case .slotItemLevelViewLowAirLevelShadow: return #colorLiteral(red: 0.095, green: 0.364, blue: 0.917, alpha: 1)
            
        case .slotItemLevelViewHighAirLevelShadow: return .yellow
            
        default: return .clear
            
        }
    }
}


class HighContrastColorSet: ColorSet {
    
    override class var shared: ColorSet { return _shared }
    
    private static let _shared = HighContrastColorSet()
    
    override subscript(named: ColorName) -> NSColor {
        
        switch named {
            
        case .damageViewBoarderSlightly: return NSColor.red
            
        case .damageViewBoarderModest: return NSColor.red
            
        case .damageViewBoarderBadly: return NSColor.red
            
        default: return super[named]
        }
    }
}

class DarkModeColorSet: ColorSet {
    
    override class var shared: ColorSet { return _shared }
    
    private static let _shared = DarkModeColorSet()
    
    override subscript(named: ColorName) -> NSColor {
        
        switch named {
            
        default: return super[named]
        }
    }
}
