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
    
    private let suppliesCell: SuppliesCell
    
    private var fuelObservation: NSKeyValueObservation?
    private var maxFuelObservation: NSKeyValueObservation?
    private var bullObservation: NSKeyValueObservation?
    private var maxBullObservation: NSKeyValueObservation?

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
    
    
    @objc var ship: Ship? {
        
        get { return suppliesCell.ship }
        set {
            suppliesCell.ship = newValue
            
            fuelObservation = suppliesCell.ship?.observe(\Ship.fuel, changeHandler: updateDisplay)
            maxFuelObservation = suppliesCell.ship?.observe(\Ship.maxFuel, changeHandler: updateDisplay)
            bullObservation = suppliesCell.ship?.observe(\Ship.bull, changeHandler: updateDisplay)
            maxBullObservation = suppliesCell.ship?.observe(\Ship.maxBull, changeHandler: updateDisplay)

            needsDisplay = true
        }
    }
    
    private func updateDisplay(ship: Ship, _: Any) {
        
        needsDisplay = true
    }
}
