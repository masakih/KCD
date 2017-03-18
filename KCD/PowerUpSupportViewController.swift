//
//  PowerUpSupportViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/25.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

class PowerUpSupportViewController: MainTabVIewItemViewController {
    let managedObjectContext = ServerDataStore.default.managedObjectContext
    
    deinit {
        shipController.removeObserver(self, forKeyPath: NSSortDescriptorsBinding)
    }
    
    @IBOutlet var shipController: NSArrayController!
    @IBOutlet weak var typeSegment: NSSegmentedControl!
    
    override var hasShipTypeSelector: Bool { return true }
    override var selectedShipType: ShipType {
        didSet {
            shipController.filterPredicate = customPredicate(for: selectedShipType)
            shipController.rearrangeObjects()
        }
    }
    override var nibName: String! {
        return "PowerUpSupportViewController"
    }
    
    var omitPredicate: NSPredicate? {
        let sd = UserDefaults.standard
        let hideKyes = [(Bool, String)]()
            .appended { (sd.hideMaxKaryoku, "isMaxKaryoku != TRUE") }
            .appended { (sd.hideMaxRaisou, "isMaxRaisou != TRUE") }
            .appended { (sd.hideMaxTaiku, "isMaxTaiku != TRUE") }
            .appended { (sd.hideMaxSoukou, "isMaxSoukou != TRUE") }
            .appended { (sd.hideMaxLucky, "isMaxLucky != TRUE") }
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
        shipController.sortDescriptors = UserDefaults.standard.powerupSupportSortDecriptors
        shipController.addObserver(self, forKeyPath: NSSortDescriptorsBinding, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == NSSortDescriptorsBinding {
            UserDefaults.standard.powerupSupportSortDecriptors = shipController.sortDescriptors
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    fileprivate func customPredicate(for type: ShipType) -> NSPredicate? {
        if let catPredicate = self.predicate(for: type) {
            if let omitPredicate = self.omitPredicate {
                return NSCompoundPredicate(type: .and,
                                           subpredicates: [omitPredicate, catPredicate])
            }
            return catPredicate
        }
        return omitPredicate
    }
    
    @IBAction func changeCategory(_ sender: AnyObject?) {
        guard let type = ShipType(rawValue: typeSegment.selectedSegment) else { return }
        shipController.filterPredicate = customPredicate(for: type)
        shipController.rearrangeObjects()
    }
}
