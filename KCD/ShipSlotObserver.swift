//
//  ShipSlotObserver.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/12/31.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

protocol ShipSlotObserving: class {
    
    func didCangeSlot0()
    func didCangeSlot1()
    func didCangeSlot2()
    func didCangeSlot3()
    func didCangeSlot4()
}

class ShipSlotObserver: NSObject {
    
    let ship: Ship
    
    weak var delegate: ShipSlotObserving?
    
    var observations: [NSKeyValueObservation] = []
    
    init(ship: Ship) {
        
        self.ship = ship
        
        super.init()
        
        let s0 = ship.observe(\.slot_0) { (_, _) in
            
            self.delegate?.didCangeSlot0()
        }
        observations.append(s0)
        
        let s1 = ship.observe(\.slot_1) { (_, _) in
            
            self.delegate?.didCangeSlot1()
        }
        observations.append(s1)
        
        let s2 = ship.observe(\.slot_2) { (_, _) in
            
            self.delegate?.didCangeSlot2()
        }
        observations.append(s2)
        
        let s3 = ship.observe(\.slot_3) { (_, _) in
            
            self.delegate?.didCangeSlot3()
        }
        observations.append(s3)
        
        let s4 = ship.observe(\.slot_4) { (_, _) in
            
            self.delegate?.didCangeSlot4()
        }
        observations.append(s4)
        
        
        let o0 = ship.observe(\.onslot_0) { (_, _) in
            
            self.delegate?.didCangeSlot0()
        }
        observations.append(o0)
        
        let o1 = ship.observe(\.onslot_1) { (_, _) in
            
            self.delegate?.didCangeSlot1()
        }
        observations.append(o1)
        
        let o2 = ship.observe(\.onslot_2) { (_, _) in
            
            self.delegate?.didCangeSlot2()
        }
        observations.append(o2)
        
        let o3 = ship.observe(\.onslot_3) { (_, _) in
            
            self.delegate?.didCangeSlot3()
        }
        observations.append(o3)
        
        let o4 = ship.observe(\.onslot_4) { (_, _) in
            
            self.delegate?.didCangeSlot4()
        }
        observations.append(o4)
        
    }

    
}
