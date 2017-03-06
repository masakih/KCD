//
//  StrengthenListItemCellView.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class StrengthenListItemCellView: NSTableCellView {
    
    class func keyPathsForValuesAffectingSecondsShipList() -> Set<String> {
        return ["objectValue"]
    }
    class func keyPathsForValuesAffectingRequiredEquipment01() -> Set<String> {
        return ["objectValue"]
    }
    class func keyPathsForValuesAffectingRequiredEquipment02() -> Set<String> {
        return ["objectValue"]
    }
    class func keyPathsForValuesAffectingRequiredEquipment03() -> Set<String> {
        return ["objectValue"]
    }
    class func keyPathsForValuesAffectingTargetEquipment() -> Set<String> {
        return ["objectValue"]
    }
    class func keyPathsForValuesAffectingRemodelEquipment() -> Set<String> {
        return ["objectValue"]
    }
    class func keyPathsForValuesAffectingNeedsScrewString01() -> Set<String> {
        return ["objectValue"]
    }
    class func keyPathsForValuesAffectingNeedsScrewString02() -> Set<String> {
        return ["objectValue"]
    }
    class func keyPathsForValuesAffectingNeedsScrewString03() -> Set<String> {
        return ["objectValue"]
    }
    
    private var item: EnhancementListItem? {
        return objectValue as? EnhancementListItem
    }
    
    var secondsShipList: String? {
        return item?.secondsShipNames.joined(separator: ", ")
    }
    var requiredEquipment01: RequiredEquipment? {
        return item?.requiredEquipments.requiredEquipments.first
    }
    var requiredEquipment02: RequiredEquipment? {
        guard let req = item?.requiredEquipments.requiredEquipments,
            req.count > 1 else { return nil }
        return req[1]
    }
    var requiredEquipment03: RequiredEquipment? {
        guard let req = item?.requiredEquipments.requiredEquipments,
            req.count > 2 else { return nil }
        return req[2]
    }
    var targetEquipment: String? {
        return item?.targetEquipment
    }
    var remodelEquipment: String? {
        return item?.remodelEquipment
    }
    var needsScrewString01: String? {
        return needsScrewString(screw: requiredEquipment01?.screw, ensureScrew: requiredEquipment01?.ensureScrew)
    }
    var needsScrewString02: String? {
        return needsScrewString(screw: requiredEquipment02?.screw, ensureScrew: requiredEquipment02?.ensureScrew)
    }
    var needsScrewString03: String? {
        return needsScrewString(screw: requiredEquipment03?.screw, ensureScrew: requiredEquipment03?.ensureScrew)
    }
    
    private func needsScrewString(screw: Int?, ensureScrew: Int?) -> String? {
        guard let screw = screw,
            let ensureScrew = ensureScrew,
            screw != 0
            else { return nil }
        let screwString = (screw == -1) ? "-" : "\(screw)"
        let ensureScrewString = (ensureScrew == -1) ? "-" : "\(ensureScrew)"
        return "\(screwString)/\(ensureScrewString)"
    }
}
