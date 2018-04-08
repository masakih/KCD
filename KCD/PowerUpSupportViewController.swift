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
    
    @IBOutlet private var shipController: NSArrayController!
    @IBOutlet private weak var typeSegment: NSSegmentedControl!
    
    private var sortDescriptorsObservation: NSKeyValueObservation?
    
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
        let predicates = [(Bool, NSPredicate)]()
            .appended { (sd[.hideMaxKaryoku], .false(#keyPath(Ship.isMaxKaryoku))) }
            .appended { (sd[.hideMaxRaisou], .false(#keyPath(Ship.isMaxRaisou))) }
            .appended { (sd[.hideMaxTaiku], .false(#keyPath(Ship.isMaxTaiku))) }
            .appended { (sd[.hideMaxSoukou], .false(#keyPath(Ship.isMaxSoukou))) }
            .appended { (sd[.hideMaxLucky], .false(#keyPath(Ship.isMaxLucky))) }
            .compactMap { (b, s) in b ? s : nil }
        
        if predicates.isEmpty {
            
            return nil
        }
        
        return .and(predicates)
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
        sortDescriptorsObservation = shipController.observe(\NSArrayController.sortDescriptors) { [weak self] _, _ in
            
            UserDefaults.standard[.powerupSupportSortDecriptors] = self?.shipController.sortDescriptors ?? []
        }
    }
    
    private func customPredicate() -> NSPredicate? {
        
        switch (shipTypePredicte(for: selectedShipType), omitPredicate) {
            
        case let (s?, o?): return .and([o, s])
            
        case let (s?, nil): return s
            
        case let (nil, o?): return o
            
        default: return nil
            
        }
    }
    
    @IBAction func changeCategory(_ sender: AnyObject?) {
        
        ShipTabType(rawValue: typeSegment.selectedSegment).map { selectedShipType = $0 }
    }
}
