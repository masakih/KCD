//
//  SuppliesView.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate var pShipStatusContext: Int = 0

class SuppliesView: NSControl {
    private let observeKeys = ["fuel", "maxFuel", "bull", "maxBull"]
    private let suppliesCell: SuppliesCell
    
    override init(frame: NSRect) {
        suppliesCell = SuppliesCell()
        super.init(frame: frame)
        self.cell = suppliesCell
    }
    required init?(coder: NSCoder) {
        suppliesCell = SuppliesCell()
        super.init(coder: coder)
        self.cell = suppliesCell
    }
    deinit {
        observeKeys.forEach {
            suppliesCell.shipStatus?.removeObserver(self, forKeyPath: $0)
        }
    }
    
    var shipStatus: Ship? {
        get { return suppliesCell.shipStatus }
        set {
            observeKeys.forEach {
                suppliesCell.shipStatus?.removeObserver(self, forKeyPath: $0)
            }
            suppliesCell.shipStatus = newValue
            observeKeys.forEach {
                suppliesCell.shipStatus?.addObserver(self, forKeyPath: $0, context: &pShipStatusContext)
            }
            needsDisplay = true
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        if context == &pShipStatusContext {
            needsDisplay = true
            return
        }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
}
