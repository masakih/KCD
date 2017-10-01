//
//  DefaultKeyExtendedValues.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/07/31.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation
import AppKit.NSColor

/// KeyedArchiving
extension UserDefaults {
    
    private func keyedArchivedObject<T>(forKey key: String) -> T? {
        
        guard let data = self.object(forKey: key) as? Data
            else { return nil }
        
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? T
    }
    
    private func setKeyedArchived(_ object: Any?, forKey key: String) {
        
        guard let object = object else {
            self.removeObject(forKey: key)
            return
        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        self.set(data, forKey: key)
    }
    
}

extension UserDefaults {
    
    subscript(key: DefaultKey<[NSSortDescriptor]>) -> [NSSortDescriptor] {
        
        get { return keyedArchivedObject(forKey: key.rawValue) ?? [] }
        set { self.setKeyedArchived(newValue, forKey: key.rawValue) }
    }
    
    subscript(key: DefaultKey<NSColor>) -> NSColor {
        
        get { return keyedArchivedObject(forKey: key.rawValue) ?? key.alternative }
        set { self.setKeyedArchived(newValue, forKey: key.rawValue) }
    }
    
    subscript(key: DefaultKey<Date>) -> Date {
        
        get { return keyedArchivedObject(forKey: key.rawValue) ?? key.alternative }
        set { self.setKeyedArchived(newValue, forKey: key.rawValue) }
    }
    
}

/// Enumlation Values
extension UserDefaults {
    
    subscript(key: DefaultKey<Debug.Level>) -> Debug.Level {
        
        get { return Debug.Level(rawValue: self.integer(forKey: key.rawValue)) ?? key.alternative }
        set { self.set(newValue.rawValue, forKey: key.rawValue) }
    }
    
    subscript(key: DefaultKey<FleetViewController.SakutekiCalclationSterategy>) -> FleetViewController.SakutekiCalclationSterategy {
        
        get { return FleetViewController.SakutekiCalclationSterategy(rawValue: self.integer(forKey: key.rawValue)) ?? key.alternative }
        set { self.set(newValue.rawValue, forKey: key.rawValue) }
    }
    
    subscript(key: DefaultKey<SlotItemWindowController.ShowType>) -> SlotItemWindowController.ShowType {
        
        get { return SlotItemWindowController.ShowType(rawValue: self.integer(forKey: key.rawValue)) ?? key.alternative }
        set { self.set(newValue.rawValue, forKey: key.rawValue) }
    }
    
    subscript(key: DefaultKey<BroserWindowController.FleetViewPosition>) -> BroserWindowController.FleetViewPosition {
        
        get { return BroserWindowController.FleetViewPosition(rawValue: self.integer(forKey: key.rawValue)) ?? key.alternative }
        set { self.set(newValue.rawValue, forKey: key.rawValue) }
    }
    
    subscript(key: DefaultKey<FleetViewController.ShipOrder>) -> FleetViewController.ShipOrder {
        
        get { return FleetViewController.ShipOrder(rawValue: self.integer(forKey: key.rawValue)) ??  key.alternative }
        set { self.set(newValue.rawValue, forKey: key.rawValue) }
    }
    
    subscript(key: DefaultKey<NSControl.ControlSize>) -> NSControl.ControlSize {
        
        get { return NSControl.ControlSize(rawValue: UInt(self.integer(forKey: key.rawValue))) ?? key.alternative }
        set { self.set(newValue.rawValue, forKey: key.rawValue) }
    }
    
}
