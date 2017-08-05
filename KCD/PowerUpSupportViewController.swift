//
//  PowerUpSupportViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/25.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class PowerUpSupportViewController: MainTabVIewItemViewController {
    
    let managedObjectContext = ServerDataStore.default.context
    
    deinit {
        
        shipController.removeObserver(self, forKeyPath: NSSortDescriptorsBinding)
    }
    
    @IBOutlet var shipController: NSArrayController!
    @IBOutlet weak var typeSegment: NSSegmentedControl!
    
    override var hasShipTypeSelector: Bool { return true }
    override var selectedShipType: ShipType {
        
        didSet {
            shipController.filterPredicate = customPredicate()
            shipController.rearrangeObjects()
        }
    }
    
    override var nibName: String! {
        
        return "PowerUpSupportViewController"
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
        shipController.addObserver(self, forKeyPath: NSSortDescriptorsBinding, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == NSSortDescriptorsBinding {
            
            UserDefaults.standard[.powerupSupportSortDecriptors] = shipController.sortDescriptors
            
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    fileprivate func customPredicate() -> NSPredicate? {
        
        switch (shipTypePredicte, omitPredicate) {
            
        case let (s?, o?): return NSCompoundPredicate(type: .and, subpredicates: [o, s])
        case let (s?, nil): return s
        case let (nil, o?): return o
        default: return nil
        }
    }
    
    @IBAction func changeCategory(_ sender: AnyObject?) {
        
        ShipType(rawValue: typeSegment.selectedSegment).map { selectedShipType = $0 }
    }
}
