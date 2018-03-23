//
//  SlotItemMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/25.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import SwiftyJSON

final class SlotItemMapper: JSONMapper {
        
    let apiResponse: APIResponse
    let configuration: MappingConfiguration<SlotItem>
    
    required init(_ apiResponse: APIResponse) {
        
        self.apiResponse = apiResponse
        self.configuration = MappingConfiguration(entity: SlotItem.entity,
                                                  dataKeys: SlotItemMapper.dataKeys(apiResponse),
                                                  editorStore: ServerDataStore.oneTimeEditor())
    }
    
    private class func dataKeys(_ apiResponse: APIResponse) -> [String] {
        
        switch apiResponse.api.endpoint {
            
        case .getShip: return ["api_data", "api_slotitem"]
            
        case .requireInfo: return ["api_data", "api_slot_item"]
            
        case .slotItem: return ["api_data"]
            
        default: return Logger.shared.log("Missing API: \(apiResponse.api)", value: ["api_data"])
        }
    }
    
    private var registerIds: [Int] = []
    private lazy var masterSlotItems: [MasterSlotItem] = {
        
        guard let store = configuration.editorStore as? ServerDataStore else { return [] }
        
        return store.sortedMasterSlotItemsById()
    }()
    
    func beginRegister(_ slotItem: SlotItem) {
        
        slotItem.alv = 0
    }
    
    func handleExtraValue(_ value: JSON, forKey key: String, to object: SlotItem) -> Bool {
        
        // 取得後破棄した装備のデータを削除するため保有IDを保存
        if key == "api_id" {
            
            guard let id = value.int else { return false }
            
            registerIds.append(id)
            
            return false
        }
        
        if key == "api_slotitem_id" {
            
            guard let id = value.int else { return false }
            
            setMaster(id, to: object)
            
            return true
        }
        
        return false
    }
    
    func finishOperating() {
        
        // getshipの時は取得した艦娘の装備のみのデータのため無視
        if apiResponse.api.endpoint == .getShip {
            
            return
        }
        
        guard let store = configuration.editorStore as? ServerDataStore else { return }
        
        store.slotItems(exclude: registerIds).forEach(store.delete)
    }
    
    private func setMaster(_ masterId: Int, to slotItem: SlotItem?) {
        
        guard let slotItem = slotItem else { return }
        
        if slotItem.slotitem_id == masterId { return }
        
        guard let mSlotItem = masterSlotItems.binarySearch(comparator: { $0.id ==? masterId }) else {
            
            return Logger.shared.log("Can not find MasterSlotItem")
        }
        
        // FUCK: 型推論がバカなのでダウンキャストしてるんだ！！！
        guard let masterSlotItem = configuration.editorStore.exchange(mSlotItem) as? MasterSlotItem else {
                
                return Logger.shared.log("Can not convert to current moc object")
        }
        
        slotItem.master_slotItem = masterSlotItem
        slotItem.slotitem_id = masterId
    }
}
