//
//  SuppliesView.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

private var pShipStatusContext: Int = 0

final class SuppliesView: NSControl {
    
    private let observeKeys = [ #keyPath(Ship.fuel),
                                #keyPath(Ship.maxFuel),
                                #keyPath(Ship.bull),
                                #keyPath(Ship.maxBull)]
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
            
            suppliesCell.ship?.removeObserver(self, forKeyPath: $0)
        }
    }
    
    @objc var ship: Ship? {
        
        get { return suppliesCell.ship }
        set {
            observeKeys.forEach {
                
                suppliesCell.ship?.removeObserver(self, forKeyPath: $0)
            }
            suppliesCell.ship = newValue
            observeKeys.forEach {
                
                suppliesCell.ship?.addObserver(self, forKeyPath: $0, context: &pShipStatusContext)
            }
            needsDisplay = true
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == &pShipStatusContext {
            
            needsDisplay = true
            
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
}
