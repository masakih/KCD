//
//  SlotItemMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/25.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import SwiftyJSON

fileprivate enum SlotItemAPI: String {
    case getMemberSlotItem = "/kcsapi/api_get_member/slot_item"
    case kousyouGetShip = "/kcsapi/api_req_kousyou/getship"
    case getMemberRequireInfo = "/kcsapi/api_get_member/require_info"
}

fileprivate func dataKey(_ apiResponse: APIResponse) -> String {
    guard let slotItemApi = SlotItemAPI(rawValue: apiResponse.api)
        else { return "api_data" }
    switch slotItemApi {
    case .kousyouGetShip: return "api_data.api_slotitem"
    case .getMemberRequireInfo: return "api_data.api_slot_item"
    default: return "api_data"
    }
}

class SlotItemMapper: JSONMapper {
    typealias ObjectType = SlotItem
    
    let apiResponse: APIResponse
    let configuration: MappingConfiguration<SlotItem>
    
    required init(_ apiResponse: APIResponse) {
        self.apiResponse = apiResponse
        self.configuration = MappingConfiguration(entity: SlotItem.entity,
                                                  dataKey: dataKey(apiResponse),
                                                  editorStore: ServerDataStore.oneTimeEditor())
    }
    
    private var registerIds: [Int] = []
    private lazy var masterSlotItems: [MasterSlotItem] = {
        return ServerDataStore.default.sortedMasterSlotItemsById()
    }()
    
    func beginRegister(_ slotItem: SlotItem) {
        slotItem.alv = 0
    }
    func handleExtraValue(_ value: JSON, forKey key: String, to object: SlotItem) -> Bool {
        // 取得後破棄した装備のデータを削除するため保有IDを保存
        if key == "api_id" {
            guard let id = value.int
                else { return false }
            registerIds.append(id)
            return false
        }
        
        if key == "api_slotitem_id" {
            guard let id = value.int
                else { return false }
            setMaster(id, to: object)
            return true
        }
        return false
    }
    func finishOperating() {
        // getshipの時は取得した艦娘の装備のみのデータのため無視
        if let slotItemApi = SlotItemAPI(rawValue: apiResponse.api),
            slotItemApi == .kousyouGetShip {
            return
        }
        guard let store = configuration.editorStore as? ServerDataStore
            else { return }
        store.slotItems(exclude: registerIds).forEach { store.delete($0) }
    }
    
    private func setMaster(_ masterId: Int, to slotItem: SlotItem?) {
        guard let slotItem = slotItem
            else { return }
        if slotItem.slotitem_id == masterId { return }
        
        guard let mSlotItem = masterSlotItems.binarySearch(comparator: { $0.id ==? masterId })
            else { return print("Can not find MasterSlotItem") }
        guard let moc = slotItem.managedObjectContext,
            let masterSlotItem = moc.object(with: mSlotItem.objectID) as? MasterSlotItem
            else { return print("Can not convert to current moc object") }
        slotItem.master_slotItem = masterSlotItem
        slotItem.slotitem_id = masterId
    }
}
