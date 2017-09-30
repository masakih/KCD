//
//  StrengthenListItem.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/24.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

protocol StrengthenListItem {
    
    var type: EquipmentType { get }
    var cellType: StrengthenListCellType.Type { get }
}

protocol StrengthenListCellType {
    
    static var cellIdentifier: NSUserInterfaceItemIdentifier { get }
    static func estimateCellHeightForItem(item: StrengthenListItem, tableView: NSTableView) -> CGFloat
    static func makeCellWithItem(item: StrengthenListItem, tableView: NSTableView, owner: AnyObject?) -> NSTableCellView
}

extension StrengthenListCellType {
    
    static func makeCellWithItem(item: StrengthenListItem, tableView: NSTableView, owner: AnyObject?) -> NSTableCellView {
        
        let v = tableView.makeView(withIdentifier: cellIdentifier, owner: nil)
        
        // swiftlint:disable:next force_cast
        return v as! NSTableCellView
    }
}

struct StrengthenListGroupCellType: StrengthenListCellType {
    
    static let cellIdentifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("GroupCell")
    
    static func estimateCellHeightForItem(item: StrengthenListItem, tableView: NSTableView) -> CGFloat {
        
        return 23.0
    }
}

final class StrengthenListGroupItem: NSObject, StrengthenListItem {
    
    @objc let name: String
    let type: EquipmentType
    let cellType: StrengthenListCellType.Type = StrengthenListGroupCellType.self
    
    init(type: EquipmentType) {
        
        self.name = SlotItemEquipTypeTransformer().transformedValue(type.rawValue) as? String ?? "Unkown"
        self.type = type
        
        super.init()
    }
}

final class StrengthenListEnhancementItem: NSObject, StrengthenListItem {
    
    let item: EnhancementListItem
    var type: EquipmentType { return item.equipmentType }
    let cellType: StrengthenListCellType.Type = StrengthenListItemCellView.self
    
    init(item: EnhancementListItem) {
        
        self.item = item
        
        super.init()
    }
 }

extension StrengthenListEnhancementItem {
    
    var identifier: String { return item.identifier }
    var weekday: Int { return item.weekday }
    var equipmentType: EquipmentType { return item.equipmentType }
    var targetEquipment: String { return item.targetEquipment }
    var remodelEquipment: String? { return item.remodelEquipment }
    var requiredEquipments: RequiredEquipmentSet { return item.requiredEquipments }
    var secondsShipNames: [String] { return item.secondsShipNames }
}
