//
//  AirPlanInfoView.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/04/29.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class AirPlanInfoView: NSTableCellView {
    
    enum Condition: Int {
        
        case normal = 1
        case tired = 2
        case bad = 3
    }
    
    @IBOutlet var planNameVew: SlotItemLevelView!
    @IBOutlet var conditionBox: NSBox!
    @IBOutlet var needSupplyField: NSTextField!
    
    @objc dynamic var condition: Int = 1 {
        
        didSet {
            guard let cond = Condition(rawValue: condition) else { return }
            
            conditionBox.fillColor = conditionColor(cond)
            conditionBox.borderColor = borderColor(cond)
        }
    }
    
    @objc dynamic var slotId: NSNumber? {
        
        didSet { planNameVew.slotItemID = slotId }
    }
    
    @objc dynamic var maxCount: Int = 0 {
        
        didSet { needSupplyField.isHidden = !needSupply() }
    }
    
    @objc dynamic var count: Int = 0 {
        
        didSet { needSupplyField.isHidden = !needSupply() }
    }
    
    private func conditionColor(_ cond: Condition) -> NSColor {
        
        switch cond {
        case .normal: return .clear
        case .tired: return #colorLiteral(red: 1, green: 0.7233425379, blue: 0.1258574128, alpha: 0.8239436619)
        case .bad: return #colorLiteral(red: 0.7320367694, green: 0.07731548697, blue: 0.06799335033, alpha: 1)
        }
    }
    
    private func borderColor(_ cond: Condition) -> NSColor {
        
        switch cond {
        case .normal: return .clear
        case .tired: return #colorLiteral(red: 0.458858192, green: 0.3335277438, blue: 0.07979661971, alpha: 1)
        case .bad: return #colorLiteral(red: 0.5462518334, green: 0.04599834234, blue: 0.04913448542, alpha: 1)
        }
    }
    
    private func needSupply() -> Bool {
        
        return (maxCount - count != 0)
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
    }
    
    deinit {
        
        unbind(NSBindingName(#keyPath(AirPlanInfoView.condition)))
        unbind(NSBindingName(#keyPath(AirPlanInfoView.slotId)))
        unbind(NSBindingName(#keyPath(AirPlanInfoView.maxCount)))
        unbind(NSBindingName(#keyPath(AirPlanInfoView.count)))
    }
    
    override func awakeFromNib() {
        
        bind(NSBindingName(#keyPath(AirPlanInfoView.condition)),
             to: self,
             withKeyPath: "objectValue.cond")
        bind(NSBindingName(#keyPath(AirPlanInfoView.slotId)),
             to: self,
             withKeyPath: "objectValue.slotid")
        bind(NSBindingName(#keyPath(AirPlanInfoView.maxCount)),
             to: self,
             withKeyPath: "objectValue.max_count")
        bind(NSBindingName(#keyPath(AirPlanInfoView.count)),
             to: self,
             withKeyPath: "objectValue.count")
    }
}
