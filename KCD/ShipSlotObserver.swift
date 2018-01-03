//
//  ShipSlotObserver.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/12/31.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

protocol ShipSlotObserverDelegate: class {
    
    func didChangeSlot0()
    func didChangeSlot1()
    func didChangeSlot2()
    func didChangeSlot3()
    func didChangeSlot4()
}

class ShipSlotObserver: NSObject {
    
    private enum SlotPosition {
        case first
        case second
        case third
        case fourth
        case fifth
    }
    
    private let ship: Ship
    
    weak var delegate: ShipSlotObserverDelegate?
    
    private var observations: [NSKeyValueObservation] = []
    
    init(ship: Ship) {
        
        self.ship = ship
        
        super.init()
        
        observeSlot()
        observeOnSlot()
    }
    
    private func observeSlot() {
        
        let keyPaths = [\Ship.slot_0, \Ship.slot_1, \Ship.slot_2, \Ship.slot_3, \Ship.slot_4]
        observe(keyPaths: keyPaths)
    }
    
    private func observeOnSlot() {
        
        let keyPaths = [\Ship.onslot_0, \Ship.onslot_1, \Ship.onslot_2, \Ship.onslot_3, \Ship.onslot_4]
        observe(keyPaths: keyPaths)
    }
    
    private func observe(keyPaths: [KeyPath<Ship, Int>]) {
        
        let positions: [SlotPosition] = [.first, .second, .third, .fourth, .fifth]
        
        observations += zip(keyPaths, positions)
            .map { [weak self] keyPath, position in
                ship.observe(keyPath) { _, _ in
                    self?.notifyChange(on: position)
                }
        }
    }
    
    private func notifyChange(on position: SlotPosition) {
        
        switch position {
            
        case .first: delegate?.didChangeSlot0()
        case .second: delegate?.didChangeSlot1()
        case .third: delegate?.didChangeSlot2()
        case .fourth: delegate?.didChangeSlot3()
        case .fifth: delegate?.didChangeSlot4()
        }
    }
}
