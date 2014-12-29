//
//  HMSuppliesCell.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/29.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMSuppliesCell: NSCell
{
	var redColor: NSColor {
		return NSColor(calibratedWhite: 0.790, alpha: 1.000)
	}
	var orangeColor: NSColor {
		return NSColor(calibratedWhite: 0.700, alpha: 1.000)
	}
	var yellowColor: NSColor {
		return NSColor(calibratedWhite: 0.550, alpha: 1.000)
	}
	var greenColor: NSColor {
		return NSColor(calibratedWhite: 0.390, alpha: 1.000)
	}
	var shipStatus: HMKCShipObject?
	let numberOfCell = 10
	func numberOfColoredCell(value: NSNumber?, maxValue: NSNumber?) -> Int {
		if value == nil { return 0 }
		if value!.integerValue >= maxValue!.integerValue { return 10 }
		let result: Double = ceil(value!.doubleValue / maxValue!.doubleValue * Double(numberOfCell))
		if result > 9 { return 9 }
		return Int(result)
	}
	var numberOfFuelColoredCell: Int {
		return numberOfColoredCell(shipStatus?.fuel, maxValue: shipStatus?.maxFuel)
	}
	var numberOfBullColoredCell: Int {
		return numberOfColoredCell(shipStatus?.bull, maxValue: shipStatus?.maxBull)
	}
	func statusColor(value: NSNumber?, maxValue: NSNumber?) -> NSColor {
		var color = greenColor
		switch numberOfColoredCell(value, maxValue: maxValue) {
		case 1, 2, 3:
			color = redColor
		case 4, 5, 6, 7:
			color = orangeColor
		case 8, 9:
			color = yellowColor
		case 10:
			color = greenColor
		default:
			println(__FUNCTION__, " unknown type")
		}
		return color
	}
	var fuelStatusColor: NSColor {
		return statusColor(shipStatus?.fuel, maxValue: shipStatus?.maxFuel)
	}
	var bullStatusColor: NSColor {
		return statusColor(shipStatus?.bull, maxValue: shipStatus?.maxBull)
	}
	
	func drawBackground(frame: NSRect) {
		NSColor(calibratedWhite: 0.632, alpha: 1.000).set()
		NSBezierPath(rect: frame).fill()
	}
	func drawFuelInterior(frame: NSRect) {
		var cellRect = NSRect()
		cellRect.origin = NSZeroPoint
		cellRect.size.width = (frame.size.width - CGFloat(numberOfCell) - 1.0) / CGFloat(numberOfCell)
		cellRect.size.height = (frame.size.height - 3.0) / 2.0
		cellRect.origin.y = cellRect.size.height + 2
		
		fuelStatusColor.set()
		for i in 0..<numberOfFuelColoredCell {
			cellRect.origin.x = CGFloat(1 + i) + cellRect.size.width * CGFloat(i)
			NSBezierPath(rect: cellRect).fill()
		}
		NSColor(calibratedWhite: 0.948, alpha: 1.000).set()
		for i in numberOfFuelColoredCell..<10 {
			cellRect.origin.x = CGFloat(1 + i) + cellRect.size.width * CGFloat(i)
			NSBezierPath(rect: cellRect).fill()
		}
	}
	func drawBullInterior(frame: NSRect) {
		var cellRect = NSRect()
		cellRect.origin = NSZeroPoint
		cellRect.size.width = (frame.size.width - CGFloat(numberOfCell) - 1.0) / CGFloat(numberOfCell)
		cellRect.size.height = (frame.size.height - 3.0) / 2.0
		cellRect.origin.y = 1
		
		bullStatusColor.set()
		for i in 0..<numberOfBullColoredCell {
			cellRect.origin.x = CGFloat(1 + i) + cellRect.size.width * CGFloat(i)
			NSBezierPath(rect: cellRect).fill()
		}
		NSColor(calibratedWhite: 0.948, alpha: 1.000).set()
		for i in numberOfBullColoredCell..<10 {
			cellRect.origin.x = CGFloat(1 + i) + cellRect.size.width * CGFloat(i)
			NSBezierPath(rect: cellRect).fill()
		}
	}
	override func drawInteriorWithFrame(cellFrame: NSRect, inView controlView: NSView) {
		drawBackground(cellFrame)
		drawFuelInterior(cellFrame)
		drawBullInterior(cellFrame)
	}
}
