//
//  SuppliesCell.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class SuppliesCell: NSCell {
    private enum ResourceType {
        case fuel
        case bull
    }
    
    private let numberOfCell = 10
    private let greenColor = NSColor(calibratedWhite: 0.39, alpha: 1.0)
    private let yellowColor = NSColor(calibratedWhite: 0.55, alpha: 1.0)
    private let orangeColor = NSColor(calibratedWhite: 0.7, alpha: 1.0)
    private let redColor = NSColor(calibratedWhite: 0.79, alpha: 1.0)
    private let borderColor = NSColor(calibratedWhite: 0.632, alpha: 1.0)
    private let backgroundColor = NSColor(calibratedWhite: 0.948, alpha: 1.0)
    
    dynamic var shipStatus: Ship?
    private var fuelStatusColor: NSColor {
        guard let s = shipStatus else { return redColor }
        return statusColor(withValue: s.fuel, max: s.maxFuel)
    }
    private var bullStatusColor: NSColor {
        guard let s = shipStatus else { return redColor }
        return statusColor(withValue: s.bull, max: s.maxBull)
    }
    private var numberOfFuelColoredCell: Int {
        guard let s = shipStatus else { return 0 }
        return numberOfColoredCell(withValue: s.fuel, max: s.maxFuel)
    }
    private var numberOgBullColoredCell: Int {
        guard let s = shipStatus else { return 0 }
        return numberOfColoredCell(withValue: s.bull, max: s.maxBull)
    }
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        drawBackground(withFrame: cellFrame)
        drawFuelInterior(withFrame: cellFrame)
        drawBullInterior(withFrame: cellFrame)
    }
    
    private func drawBackground(withFrame cellFrame: NSRect) {
        let path = NSBezierPath(rect: cellFrame)
        borderColor.set()
        path.fill()
    }
    private func color(of type: ResourceType, position: Int, border: Int) -> NSColor {
        if position >= border { return backgroundColor }
        return type == .fuel ? fuelStatusColor : bullStatusColor
    }
    private func drawResource(withFrame cellFrame: NSRect, border: Int, type: ResourceType) {
        let height: CGFloat = (NSHeight(cellFrame) - 3.0) / 2.0
        let width: CGFloat = (NSWidth(cellFrame) - CGFloat(numberOfCell) - 1.0) / CGFloat(numberOfCell)
        let y: CGFloat = type == .fuel ? height + 2.0 : 1.0
        for i in 0...10 {
            let x: CGFloat = CGFloat(1 + i) + width * CGFloat(i)
            let cellRect = NSMakeRect(x, y, width, height)
            color(of: type, position: i, border: border).set()
            NSBezierPath(rect: cellRect).fill()
        }
    }
    private func drawFuelInterior(withFrame cellFrame: NSRect) {
        drawResource(withFrame: cellFrame, border: numberOfFuelColoredCell, type: .fuel)
    }
    private func drawBullInterior(withFrame cellFrame: NSRect) {
        drawResource(withFrame: cellFrame, border: numberOgBullColoredCell, type: .bull)
    }
    private func numberOfColoredCell(withValue value: Int, max: Int) -> Int {
        if value >= max { return 10 }
        let retio = ceil( Double(value) / Double(max) * Double(numberOfCell) )
        if retio > 9 { return 9 }
        return Int(retio)
    }
    private func statusColor(withValue value: Int, max: Int) -> NSColor {
        switch numberOfColoredCell(withValue: value, max: max) {
        case 1, 2, 3: return redColor
        case 4, 5, 6, 7: return orangeColor
        case 8, 9: return yellowColor
        default: return greenColor
        }
    }
}
