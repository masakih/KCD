//
//  ColorSet.swift
//  KCD
//
//  Created by Hori,Masaki on 2018/06/24.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Cocoa

enum AppearanceMode {
    
    case normal
    
    case highContrast
    
    case dark
    
    case highContrastDark
}

extension AppearanceMode {
    
    static var current: AppearanceMode {
        
        if #available(macOS 10.14, *) {
            
            return currentMode1014()
        }
        
        if NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast {
            
            return .highContrast
        }
        
        return .normal
    }
    
    @available(macOS 10.14, *)
    private static func currentMode1014() -> AppearanceMode {
        
        switch NSAppearance.current.name {
            
        case .aqua: return .normal
            
        /// not available in macOS 10.13 SDK
//        case .accessibilityHighContrastAqua: return .highContrast
//
//        case .darkAqua: return .dark
//
//        case .accessibilityHighContrastDarkAqua: return .highContrastDark
            
        default: return .normal
        }
    }
}

struct ColorName: Equatable {
    
    private let name: String
    
    private init(_ name: String) {
        
        self.name = name
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

protocol ColorSet {
    
    subscript(named: ColorName) -> NSColor { get }
}


struct ColorSetManager {
    
    static var current: ColorSet {
        
        switch AppearanceMode.current {
            
        case .normal: return BaseColorSet.shared
            
        case .highContrast: return HighContrastColorSet.shared
            
        case .dark: return DarkModeColorSet.shared
            
        case .highContrastDark: return HighContrastDarkModeColorSet.shared
        }
    }
}

private struct BaseColorSet: ColorSet {
    
    static let shared = BaseColorSet()
    
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


private protocol SpecialColorSet: ColorSet {
    
    func color(named: ColorName) -> NSColor?
}

private extension SpecialColorSet {
    
    subscript(named: ColorName) -> NSColor {
        
        return color(named: named) ?? BaseColorSet.shared[named]
    }
}


private struct HighContrastColorSet: SpecialColorSet {
    
    static let shared = HighContrastColorSet()
    
    func color(named: ColorName) -> NSColor? {
        
        switch named {
            
        case .damageViewBoarderSlightly: return .red
            
        case .damageViewBoarderModest: return .red
            
        case .damageViewBoarderBadly: return .red
            
        default: return nil
        }
    }
}

private struct DarkModeColorSet: SpecialColorSet {
    
    static let shared = DarkModeColorSet()
    
    func color(named: ColorName) -> NSColor? {
        
        switch named {
            
        default: return nil
        }
    }
}

private struct HighContrastDarkModeColorSet: SpecialColorSet {
    
    static let shared = HighContrastDarkModeColorSet()
    
    func color(named: ColorName) -> NSColor? {
        
        return nil
    }
}
