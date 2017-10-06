//
//  CombileViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/25.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class CombileViewController: NSViewController {
    
    let fleet1 = FleetViewController(viewType: .miniVierticalType)!
    let fleet2 = FleetViewController(viewType: .miniVierticalType)!
    
    @IBOutlet weak var placeholder1: NSView!
    @IBOutlet weak var placeholder2: NSView!
    
    @objc dynamic var fleet1TPValue: Int = 0 {
        willSet {
            willChangeValue(forKey: #keyPath(TPValue))
            willChangeValue(forKey: #keyPath(BRankTPValue))
        }
        didSet {
            didChangeValue(forKey: #keyPath(TPValue))
            didChangeValue(forKey: #keyPath(BRankTPValue))
        }
    }
    @objc dynamic var fleet2TPValue: Int = 0 {
        willSet {
            willChangeValue(forKey: #keyPath(TPValue))
            willChangeValue(forKey: #keyPath(BRankTPValue))
        }
        didSet {
            didChangeValue(forKey: #keyPath(TPValue))
            didChangeValue(forKey: #keyPath(BRankTPValue))
        }
    }
    @objc dynamic var TPValue: Int { return fleet1TPValue + fleet2TPValue }
    @objc dynamic var BRankTPValue: Int { return Int(floor(Double(TPValue) * 0.7)) }
    
    @objc dynamic var fleet1Seiku: Int = 0 {
        willSet {
            willChangeValue(forKey: #keyPath(seiku))
        }
        didSet {
            didChangeValue(forKey: #keyPath(seiku))
        }
    }
    @objc dynamic var fleet2Seiku: Int = 0 {
        willSet {
            willChangeValue(forKey: #keyPath(seiku))
        }
        didSet {
            didChangeValue(forKey: #keyPath(seiku))
        }
    }
    @objc dynamic var seiku: Int { return fleet1Seiku + fleet2Seiku }
    
    @objc dynamic var fleet1CalculatedSeiku: Int = 0 {
        willSet {
            willChangeValue(forKey: #keyPath(seiku))
        }
        didSet {
            didChangeValue(forKey: #keyPath(seiku))
        }
    }
    @objc dynamic var fleet2CalculatedSeiku: Int = 0 {
        willSet {
            willChangeValue(forKey: #keyPath(calculatedSeiku))
        }
        didSet {
            didChangeValue(forKey: #keyPath(calculatedSeiku))
        }
    }
    @objc dynamic var calculatedSeiku: Int { return fleet1CalculatedSeiku + fleet2CalculatedSeiku }
    
    override var nibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let placeholders: [NSView] = [placeholder1, placeholder2]
        let fleets = [fleet1, fleet2]
        zip(placeholders, fleets).enumerated().forEach {
            
            $0.element.1.view.frame = $0.element.0.frame
            $0.element.1.view.autoresizingMask = $0.element.0.autoresizingMask
            $0.element.0.superview?.replaceSubview($0.element.0, with: $0.element.1.view)
            $0.element.1.fleetNumber = $0.offset + 1
        }
        
        bind(NSBindingName(#keyPath(fleet1TPValue)), to: fleet1, withKeyPath: #keyPath(FleetViewController.totalTPValue))
        bind(NSBindingName(#keyPath(fleet2TPValue)), to: fleet2, withKeyPath: #keyPath(FleetViewController.totalTPValue))
        
        bind(NSBindingName(#keyPath(fleet1Seiku)), to: fleet1, withKeyPath: #keyPath(FleetViewController.totalSeiku))
        bind(NSBindingName(#keyPath(fleet2Seiku)), to: fleet2, withKeyPath: #keyPath(FleetViewController.totalSeiku))
        
        bind(NSBindingName(#keyPath(fleet1CalculatedSeiku)), to: fleet1, withKeyPath: #keyPath(FleetViewController.totalCalclatedSeiku))
        bind(NSBindingName(#keyPath(fleet2CalculatedSeiku)), to: fleet2, withKeyPath: #keyPath(FleetViewController.totalCalclatedSeiku))
    }
    
    deinit {
        
        unbind(NSBindingName(#keyPath(fleet1TPValue)))
        unbind(NSBindingName(#keyPath(fleet2TPValue)))
        
        unbind(NSBindingName(#keyPath(fleet1Seiku)))
        unbind(NSBindingName(#keyPath(fleet2Seiku)))
        
        unbind(NSBindingName(#keyPath(fleet1CalculatedSeiku)))
        unbind(NSBindingName(#keyPath(fleet2CalculatedSeiku)))
    }
}
