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
    }
}
