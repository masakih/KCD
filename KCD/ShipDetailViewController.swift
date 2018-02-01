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

private func nibNameFor(_ type: ShipDetailViewType) -> NSNib.Name {
    
    switch type {
    case .full: return ShipDetailViewController.nibName
    case .medium: return NSNib.Name("MediumShipViewController")
    case .minimum: return NSNib.Name("MediumShipViewController")
    }
}

final class ShipDetailViewController: NSViewController {
    
    let type: ShipDetailViewType
    @objc let managedObjectContext = ServerDataStore.default.context
    
    init?(type: ShipDetailViewType) {
        
        self.type = type
        
        super.init(nibName: nibNameFor(type), bundle: nil)
        
        NotificationCenter
            .default
            .addObserver(forName: .DidUpdateGuardEscape, object: nil, queue: nil) { [weak self] _ in
                
                self?.guardEscaped = self?.ship?.guardEscaped ?? false
        }
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("not implemented")
    }
    
    deinit {
        
        damageView.unbind(NSBindingName(#keyPath(DamageView.damageType)))
        [slot00Field, slot01Field, slot02Field, slot03Field]
            .forEach { $0?.unbind(NSBindingName(#keyPath(SlotItemLevelView.slotItemID))) }
    }
    
    @IBOutlet private weak var supply: SuppliesView!
    @IBOutlet private weak var guardEscapedView: GuardEscapedView!
    @IBOutlet private weak var damageView: DamageView!
    @IBOutlet private weak var slot00Field: SlotItemLevelView!
    @IBOutlet private weak var slot01Field: SlotItemLevelView!
    @IBOutlet private weak var slot02Field: SlotItemLevelView!
    @IBOutlet private weak var slot03Field: SlotItemLevelView!
    
    var observer: ShipSlotObserver?
    
    @objc dynamic var guardEscaped: Bool = false {
        
        didSet {
            guardEscapedView.isHidden = !guardEscaped
        }
    }
    
    @objc dynamic var ship: Ship? {
        
        didSet {
            
            defer {
                didChangeSlot0()
                didChangeSlot1()
                didChangeSlot2()
                didChangeSlot3()
                didChangeSlot4()
            }
            
            supply.ship = ship
            
            observer = ship.map { ship in
                
                let observer  = ShipSlotObserver(ship: ship)
                observer.delegate = self
                
                return observer
            }
            
            // slot の lv, alv の反映のため
            let fields = [slot00Field, slot01Field, slot02Field, slot03Field]
            fields.forEach { $0?.unbind(NSBindingName(#keyPath(SlotItemLevelView.slotItemID))) }
            
            damageView.unbind(NSBindingName(#keyPath(DamageView.damageType)))
            
            if let ship = ship {
                
                zip(fields, [#keyPath(Ship.slot_0), #keyPath(Ship.slot_1), #keyPath(Ship.slot_2), #keyPath(Ship.slot_3)])
                    .forEach { feild, keyPath in
                        feild?.bind(NSBindingName(#keyPath(SlotItemLevelView.slotItemID)), to: ship, withKeyPath: keyPath)
                }
                
                damageView.bind(NSBindingName(#keyPath(DamageView.damageType)), to: ship, withKeyPath: #keyPath(Ship.status))
                
            } else {
                
                fields.forEach { $0?.slotItemID = nil }
                
                damageView.damageType = 0
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        damageView.setFrameOrigin(.zero)
        view.addSubview(damageView)
        
        guardEscapedView.setFrameOrigin(.zero)
        view.addSubview(guardEscapedView)
        switch type {
        case .medium, .minimum:
            guardEscapedView.controlSize = .mini
            
        default: break
        }
        
    }
}

extension ShipDetailViewController: ShipSlotObserverDelegate {
    
    func didChangeSlot0() {
        
        notifyChangeValue(forKey: #keyPath(planeString0))
        notifyChangeValue(forKey: #keyPath(planeString0Color))
    }
    
    func didChangeSlot1() {
        
        notifyChangeValue(forKey: #keyPath(planeString1))
        notifyChangeValue(forKey: #keyPath(planeString1Color))
    }
    
    func didChangeSlot2() {
        
        notifyChangeValue(forKey: #keyPath(planeString2))
        notifyChangeValue(forKey: #keyPath(planeString2Color))
    }
    
    func didChangeSlot3() {
        
        notifyChangeValue(forKey: #keyPath(planeString3))
        notifyChangeValue(forKey: #keyPath(planeString3Color))
    }
    
    func didChangeSlot4() {
        
        notifyChangeValue(forKey: #keyPath(planeString4))
        notifyChangeValue(forKey: #keyPath(planeString4Color))
    }
}

private let allPlaneTypes: [Int] = [6, 7, 8, 9, 10, 11, 25, 26, 41, 45, 56, 57, 58, 59]
extension ShipDetailViewController {
    
    // MARK: - Plane count strings
    private enum PlaneState {
        
        case cannotEquip
        case notEquip(Int)
        case equiped(Int, Int)
    }
    
    private func planState(_ index: Int) -> PlaneState {
        
        guard let ship = ship else { return .cannotEquip }
        
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
        case .cannotEquip: return nil
        case .notEquip(let max): return "\(max)"
        case .equiped(let count, let max): return "\(count)/\(max)"
        }
    }
    
    @objc dynamic var planeString0: String? { return planeString(0) }
    @objc dynamic var planeString1: String? { return planeString(1) }
    @objc dynamic var planeString2: String? { return planeString(2) }
    @objc dynamic var planeString3: String? { return planeString(3) }
    @objc dynamic var planeString4: String? { return planeString(4) }
    
    // MARK: - Plane count string color
    private func planeStringColor(_ index: Int) -> NSColor {
        
        switch planState(index) {
        case .cannotEquip: return NSColor.controlTextColor
        case .notEquip: return NSColor.disabledControlTextColor
        case .equiped: return NSColor.controlTextColor
        }
    }
    
    @objc dynamic var planeString0Color: NSColor { return planeStringColor(0) }
    @objc dynamic var planeString1Color: NSColor { return planeStringColor(1) }
    @objc dynamic var planeString2Color: NSColor { return planeStringColor(2) }
    @objc dynamic var planeString3Color: NSColor { return planeStringColor(3) }
    @objc dynamic var planeString4Color: NSColor { return planeStringColor(4) }
}

extension ShipDetailViewController: NibLoadable {}
