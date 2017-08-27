//
//  ShipDetailViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/25.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

enum ShipDetailViewType {
    
    case full
    case medium
    case minimum
}

private func nibNameFor(_ type: ShipDetailViewType) -> String {
    
    switch type {
    case .full: return "ShipDetailViewController"
    case .medium: return "MediumShipViewController"
    case .minimum: return "MediumShipViewController"
    }
}

fileprivate var shipContext: Int = 0
fileprivate var equippedItem0Context: Int = 0
fileprivate var equippedItem1Context: Int = 0
fileprivate var equippedItem2Context: Int = 0
fileprivate var equippedItem3Context: Int = 0
fileprivate var equippedItem4Context: Int = 0

final class ShipDetailViewController: NSViewController {
    
    let type: ShipDetailViewType
    let managedObjectContext = ServerDataStore.default.context
    
    init?(type: ShipDetailViewType) {
        
        self.type = type
        
        super.init(nibName: nibNameFor(type), bundle: nil)
        
        NotificationCenter
            .default
            .addObserver(forName: .DidUpdateGuardEscape, object: nil, queue: nil) { [weak self] _ in
                
                guard let `self` = self else { return }
                
                self.guardEscaped = self.ship?.guardEscaped ?? false
        }
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("not implemented")
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        damageView.unbind(#keyPath(DamageView.damageType))
        supply.unbind(#keyPath(SuppliesView.shipStatus))
        [slot00Field, slot01Field, slot02Field, slot03Field]
            .forEach { $0?.unbind(#keyPath(SlotItemLevelView.slotItemID)) }
        
        shipController.removeObject(self)
    }
    
    
    @IBOutlet weak var supply: SuppliesView!
    @IBOutlet weak var guardEscapedView: GuardEscapedView!
    @IBOutlet weak var damageView: DamageView!
    @IBOutlet weak var slot00Field: SlotItemLevelView!
    @IBOutlet weak var slot01Field: SlotItemLevelView!
    @IBOutlet weak var slot02Field: SlotItemLevelView!
    @IBOutlet weak var slot03Field: SlotItemLevelView!
    @IBOutlet var shipController: NSObjectController!
    
    dynamic var guardEscaped: Bool = false {
        
        didSet {
            guardEscapedView.isHidden = !guardEscaped
        }
    }
    
    dynamic var ship: Ship? {
        
        get { return shipController.content as? Ship }
        set {
            
            shipController.fetchPredicate = NSPredicate(format: "id = %ld", newValue?.id ?? 0)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        damageView.setFrameOrigin(.zero)
        view.addSubview(damageView)
        damageView.bind(#keyPath(DamageView.damageType),
                        to: shipController,
                        withKeyPath: "selection.status", options: nil)
        
        supply.bind(#keyPath(SuppliesView.shipStatus),
                    to: shipController,
                    withKeyPath: "selection.self", options: nil)
        
        guardEscapedView.setFrameOrigin(.zero)
        view.addSubview(guardEscapedView)
        switch type {
        case .medium, .minimum:
            guardEscapedView.controlSize = .mini
            
        default: break
        }
        
        let fields = [slot00Field, slot01Field, slot02Field, slot03Field]
        let keypath = ["selection.slot_0", "selection.slot_1", "selection.slot_2", "selection.slot_3"]
        zip(fields, keypath).forEach {
            
            $0.0?.bind(#keyPath(SlotItemLevelView.slotItemID), to: shipController, withKeyPath: $0.1, options: nil)
        }
        
        // observe slotitems count
        shipController.addObserver(self, forKeyPath: "selection", context: &shipContext)
        
        shipController.addObserver(self, forKeyPath: "selection.slot_0", context: &equippedItem0Context)
        shipController.addObserver(self, forKeyPath: "selection.onslot_0", context: &equippedItem0Context)
        shipController.addObserver(self, forKeyPath: "selection.master_ship.maxeq_0", context: &equippedItem0Context)
        
        shipController.addObserver(self, forKeyPath: "selection.slot_1", context: &equippedItem1Context)
        shipController.addObserver(self, forKeyPath: "selection.onslot_1", context: &equippedItem1Context)
        shipController.addObserver(self, forKeyPath: "selection.master_ship.maxeq_1", context: &equippedItem1Context)
        
        shipController.addObserver(self, forKeyPath: "selection.slot_2", context: &equippedItem2Context)
        shipController.addObserver(self, forKeyPath: "selection.onslot_2", context: &equippedItem2Context)
        shipController.addObserver(self, forKeyPath: "selection.master_ship.maxeq_2", context: &equippedItem2Context)
        
        shipController.addObserver(self, forKeyPath: "selection.slot_3", context: &equippedItem3Context)
        shipController.addObserver(self, forKeyPath: "selection.onslot_3", context: &equippedItem3Context)
        shipController.addObserver(self, forKeyPath: "selection.master_ship.maxeq_3", context: &equippedItem3Context)
        
        shipController.addObserver(self, forKeyPath: "selection.slot_4", context: &equippedItem4Context)
        shipController.addObserver(self, forKeyPath: "selection.onslot_4", context: &equippedItem4Context)
        shipController.addObserver(self, forKeyPath: "selection.master_ship.maxeq_4", context: &equippedItem4Context)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == &shipContext {
            
            notifyChangeValue(forKey: "planeString0")
            notifyChangeValue(forKey: "planeString0Color")
            notifyChangeValue(forKey: "planeString1")
            notifyChangeValue(forKey: "planeString1Color")
            notifyChangeValue(forKey: "planeString2")
            notifyChangeValue(forKey: "planeString2Color")
            notifyChangeValue(forKey: "planeString3")
            notifyChangeValue(forKey: "planeString3Color")
            notifyChangeValue(forKey: "planeString4")
            notifyChangeValue(forKey: "planeString4Color")
            
            return
        }
        if context == &equippedItem0Context {
            
            notifyChangeValue(forKey: "planeString0")
            notifyChangeValue(forKey: "planeString0Color")
            
            return
        }
        if context == &equippedItem1Context {
            
            notifyChangeValue(forKey: "planeString1")
            notifyChangeValue(forKey: "planeString1Color")
            
            return
        }
        if context == &equippedItem2Context {
            
            notifyChangeValue(forKey: "planeString2")
            notifyChangeValue(forKey: "planeString2Color")
            
            return
        }
        if context == &equippedItem3Context {
            
            notifyChangeValue(forKey: "planeString3")
            notifyChangeValue(forKey: "planeString3Color")
            
            return
        }
        if context == &equippedItem4Context {
            
            notifyChangeValue(forKey: "planeString4")
            notifyChangeValue(forKey: "planeString4Color")
            
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
}


fileprivate let allPlaneTypes: [Int] = [6, 7, 8, 9, 10, 11, 25, 26, 41, 45, 56, 57, 58, 59]


extension ShipDetailViewController {
    
    // MARK: - Plane count strings
    private enum PlaneState {
        
        case cannotEquip
        case notEquip(Int)
        case equiped(Int, Int)
    }
    
    private func planState(_ index: Int) -> PlaneState {
        
        guard let ship = ship
            else { return .cannotEquip }
        
        let itemId = ship.slotItemId(index)
        let maxCount = ship.slotItemMax(index)
        
        if maxCount == 0 { return .cannotEquip }
        if itemId == -1 { return .notEquip(maxCount) }
        
        if let item = ship.slotItem(index),
            allPlaneTypes.contains(item.master_slotItem.type_2) {
            
            return .equiped(ship.slotItemCount(index), maxCount)
        }
        
        return .notEquip(maxCount)
    }
    
    private func planeString(_ index: Int) -> String? {
        
        switch planState(index) {
        case .cannotEquip:
            return nil
        case .notEquip(let max):
            return "\(max)"
        case .equiped(let count, let max):
            return "\(count)/\(max)"
        }
    }
    
    dynamic var planeString0: String? { return planeString(0) }
    
    dynamic var planeString1: String? { return planeString(1) }
    
    dynamic var planeString2: String? { return planeString(2) }
    
    dynamic var planeString3: String? { return planeString(3) }
    
    dynamic var planeString4: String? { return planeString(4) }
    
    // MARK: - Plane count string color
    private func planeStringColor(_ index: Int) -> NSColor {
        
        switch planState(index) {
        case .cannotEquip: return NSColor.controlTextColor
        case .notEquip: return NSColor.disabledControlTextColor
        case .equiped: return NSColor.controlTextColor
        }
    }
    
    dynamic var planeString0Color: NSColor { return planeStringColor(0) }
    
    dynamic var planeString1Color: NSColor { return planeStringColor(1) }
    
    dynamic var planeString2Color: NSColor { return planeStringColor(2) }
    
    dynamic var planeString3Color: NSColor { return planeStringColor(3) }
    
    dynamic var planeString4Color: NSColor { return planeStringColor(4) }
}
