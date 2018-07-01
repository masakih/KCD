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
    
    static let conditionBindingName = NSBindingName(#keyPath(AirPlanInfoView.condition))
    static let slotIDBindingName = NSBindingName(#keyPath(AirPlanInfoView.slotId))
    static let maxCountBindingName = NSBindingName(#keyPath(AirPlanInfoView.maxCount))
    static let countBindingName = NSBindingName(#keyPath(AirPlanInfoView.count))
    
    @IBOutlet private var planNameVew: SlotItemLevelView!
    @IBOutlet private var conditionBox: NSBox!
    @IBOutlet private var needSupplyField: NSTextField!
    
    @objc dynamic var condition: Int = 1 {
        
        didSet {
            
            guard let cond = Condition(rawValue: condition) else {
                
                return
            }
            
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
            
        case .normal: return ColorSet.current[.airPlanInforViewNormal]
            
        case .tired: return ColorSet.current[.airPlanInforViewTired]
            
        case .bad: return ColorSet.current[.airPlanInforViewBad]
            
        }
    }
    
    private func borderColor(_ cond: Condition) -> NSColor {
        
        switch cond {
            
        case .normal: return ColorSet.current[.airPlanInforViewBoarderNormal]
            
        case .tired: return ColorSet.current[.airPlanInforViewBoarderTired]
            
        case .bad: return ColorSet.current[.airPlanInforViewBoarderBad]
            
        }
    }
    
    private func needSupply() -> Bool {
        
        return (maxCount - count != 0)
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
    }
    
    deinit {
        
        unbind(AirPlanInfoView.conditionBindingName)
        unbind(AirPlanInfoView.slotIDBindingName)
        unbind(AirPlanInfoView.maxCountBindingName)
        unbind(AirPlanInfoView.countBindingName)
    }
    
    override func awakeFromNib() {
        
        bind(AirPlanInfoView.conditionBindingName, to: self, withKeyPath: "objectValue.cond")
        bind(AirPlanInfoView.slotIDBindingName, to: self, withKeyPath: "objectValue.slotid")
        bind(AirPlanInfoView.maxCountBindingName, to: self, withKeyPath: "objectValue.max_count")
        bind(AirPlanInfoView.countBindingName, to: self, withKeyPath: "objectValue.count")
    }
}
