//
//  StrengthenListItemCellView.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class StrengthenListItemCellView: NSTableCellView {
    
    @objc override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        
        switch key {
            
        case #keyPath(secondsShipList),
             #keyPath(requiredEquipment01), #keyPath(requiredEquipment02), #keyPath(requiredEquipment03),
             #keyPath(targetEquipment), #keyPath(remodelEquipment),
             #keyPath(needsScrewString01), #keyPath(needsScrewString02), #keyPath(needsScrewString03):
            
            return [#keyPath(objectValue)]
            
        default: return []
        }
    }
    
    private var item: StrengthenListEnhancementItem? {
        
        return objectValue as? StrengthenListEnhancementItem
    }
    
    @objc var secondsShipList: String? {
        
        return item?.secondsShipNames.joined(separator: ", ")
    }
    
    @objc var requiredEquipment01: RequiredEquipment? {
        
        return item?.requiredEquipments.requiredEquipments.first
    }
    
    @objc var requiredEquipment02: RequiredEquipment? {
        
        guard let req = item?.requiredEquipments.requiredEquipments, req.count > 1 else { return nil }
        
        return req[1]
    }
    
    @objc var requiredEquipment03: RequiredEquipment? {
        
        guard let req = item?.requiredEquipments.requiredEquipments, req.count > 2 else { return nil }
        
        return req[2]
    }
    
    @objc var targetEquipment: String? {
        return item?.targetEquipment
    }
    
    @objc var remodelEquipment: String? {
        
        return item?.remodelEquipment
    }
    
    @objc var needsScrewString01: String? {
        
        return needsScrewString(screw: requiredEquipment01?.screw, ensureScrew: requiredEquipment01?.ensureScrew)
    }
    
    @objc var needsScrewString02: String? {
        
        return needsScrewString(screw: requiredEquipment02?.screw, ensureScrew: requiredEquipment02?.ensureScrew)
    }
    
    @objc var needsScrewString03: String? {
        
        return needsScrewString(screw: requiredEquipment03?.screw, ensureScrew: requiredEquipment03?.ensureScrew)
    }
    
    private func needsScrewString(screw: Int?, ensureScrew: Int?) -> String? {
        
        guard let screw = screw else { return nil }
        guard let ensureScrew = ensureScrew else { return nil }
        guard ensureScrew != 0 else { return nil }
        
        let screwString = (screw == -1) ? "-" : "\(screw)"
        let ensureScrewString = (ensureScrew == -1) ? "-" : "\(ensureScrew)"
        
        return "\(screwString)/\(ensureScrewString)"
    }
}

extension StrengthenListItemCellView: StrengthenListCellType {
    
    static var cellIdentifier: NSUserInterfaceItemIdentifier {
        
        return NSUserInterfaceItemIdentifier("ItemCell")
    }
    
    static func estimateCellHeightForItem(item: StrengthenListItem, tableView: NSTableView) -> CGFloat {
        
        return 103.0
    }
}
