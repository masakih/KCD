//
//  HMSuppliesView.swift
//  KCD
//
//  Created by Hori,Masaki on 2014/12/29.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HMSuppliesView: NSControl
{
	override init(frame: NSRect) {
		suppliesCell = HMSuppliesCell()
		super.init(frame: frame)
		setCell(suppliesCell)
	}
	required init?(coder: NSCoder) {
		suppliesCell = HMSuppliesCell()
		super.init(coder: coder)
		setCell(suppliesCell)
	}
	
	let suppliesCell: HMSuppliesCell;
	
	var shipStatus: HMKCShipObject? {
		get {
			return suppliesCell.shipStatus
		}
		set {
			suppliesCell.shipStatus?.removeObserver(self, forKeyPath: "fuel")
			suppliesCell.shipStatus?.removeObserver(self, forKeyPath: "maxFuel")
			suppliesCell.shipStatus?.removeObserver(self, forKeyPath: "bull")
			suppliesCell.shipStatus?.removeObserver(self, forKeyPath: "maxBull")
			
			suppliesCell.shipStatus = newValue
			
			if let shipStatus = suppliesCell.shipStatus {
				shipStatus.addObserver(self, forKeyPath: "fuel", options: .New, context: nil)
				shipStatus.addObserver(self, forKeyPath: "maxFuel", options: .New, context: nil)
				shipStatus.addObserver(self, forKeyPath: "bull", options: .New, context: nil)
				shipStatus.addObserver(self, forKeyPath: "maxBull", options: .New, context: nil)
			}
			setNeedsDisplay()
		}
	}
	
	override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
		switch keyPath {
		case "fuel", "maxFuel", "bull", "maxBull":
			setNeedsDisplay()
		default:
			super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
		}
	}
}
