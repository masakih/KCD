//
//  PowerUpSupportViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/25.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class PowerUpSupportViewController: MainTabVIewItemViewController {
    
    @objc let managedObjectContext = ServerDataStore.default.context
    
    deinit {
        
        shipController.removeObserver(self, forKeyPath: NSBindingName.sortDescriptors.rawValue)
    }
    
    @IBOutlet var shipController: NSArrayController!
    @IBOutlet weak var typeSegment: NSSegmentedControl!
    
    override var hasShipTypeSelector: Bool { return true }
    override var selectedShipType: ShipTabType {
        
        didSet {
            shipController.filterPredicate = customPredicate()
            shipController.rearrangeObjects()
        }
    }
    
    override var nibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    var omitPredicate: NSPredicate? {
        
        let sd = UserDefaults.standard
        let hideKyes = [(Bool, String)]()
            .appended { (sd[.hideMaxKaryoku], "isMaxKaryoku != TRUE") }
            .appended { (sd[.hideMaxRaisou], "isMaxRaisou != TRUE") }
            .appended { (sd[.hideMaxTaiku], "isMaxTaiku != TRUE") }
            .appended { (sd[.hideMaxSoukou], "isMaxSoukou != TRUE") }
            .appended { (sd[.hideMaxLucky], "isMaxLucky != TRUE") }
            .flatMap { (b, s) in b ? s : nil }
        
        if hideKyes.isEmpty { return nil }
        
        return NSPredicate(format: hideKyes.joined(separator: " AND "))
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        changeCategory(nil)
        
        do {
            
            try shipController.fetch(with: nil, merge: true)
            
        } catch {
            
            fatalError("PowerUpSupportViewController: can not fetch. \(error)")
            
        }
        
        shipController.sortDescriptors = UserDefaults.standard[.powerupSupportSortDecriptors]
        shipController.addObserver(self, forKeyPath: NSBindingName.sortDescriptors.rawValue, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == NSBindingName.sortDescriptors.rawValue {
            
            UserDefaults.standard[.powerupSupportSortDecriptors] = shipController.sortDescriptors
            
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    private func customPredicate() -> NSPredicate? {
        
        switch (shipTypePredicte, omitPredicate) {
            
        case let (s?, o?): return NSCompoundPredicate(type: .and, subpredicates: [o, s])
        case let (s?, nil): return s
        case let (nil, o?): return o
        default: return nil
        }
    }
    
    @IBAction func changeCategory(_ sender: AnyObject?) {
        
        ShipTabType(rawValue: typeSegment.selectedSegment).map { selectedShipType = $0 }
    }
}
