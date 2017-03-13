//
//  ChangeHenseiCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/09.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

enum ChangeHenseiType: Int {
    case append
    case replace
    case remove
    case removeAllWithoutFlagship
}

extension Notification.Name {
    static let HenseiDidChange = Notification.Name("com.masakih.KCD.Notification.HenseiDidChange")
}

class HenseiDidChangeUserInfo: NSObject {
    let type: ChangeHenseiType
    
    let fleetNumber: Int
    let position: Int
    let shipID: Int
    
    let replaceFleetNumber: Int?
    let replacePosition: Int?
    let replaceShipID: Int?
    
    var objcType: Int { return type.rawValue }
    var objcReplaceFleetNumbner: NSNumber? { return replaceFleetNumber as NSNumber?? ?? nil }
    var objcReplacePosition: NSNumber? { return replacePosition as NSNumber?? ?? nil }
    var objcReplaceShipID: NSNumber? { return replaceShipID as NSNumber?? ?? nil }
    
    required init(type: ChangeHenseiType,
                  fleetNumber: Int,
                  position: Int,
                  shipID: Int,
                  replaceFleetNumber: Int? = nil,
                  replacePosition: Int? = nil,
                  replaceShipID: Int? = nil) {
        self.type = type
        self.fleetNumber = fleetNumber
        self.position = position
        self.shipID = shipID
        self.replaceFleetNumber = replaceFleetNumber
        self.replacePosition = replacePosition
        self.replaceShipID = replaceShipID
        super.init()
    }
}

class ChangeHenseiCommand: JSONCommand {
    static let userInfoKey = "HenseiDidChangeUserInfoKey"
    
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_req_hensei/change" { return true }
        return false
    }
    
    // api_ship_id の値
    // ship_id > 0 : 艦娘のID　append or replace
    // ship_id == -1 : remove.
    // ship_id == -2 : remove all without flag ship.
    override func execute() {
        guard let deckNumber = arguments["api_id"].flatMap({ Int($0) }),
            let shipId = arguments["api_ship_id"].flatMap({ Int($0) }),
            let shipIndex = arguments["api_ship_idx"].flatMap({ Int($0) })
            else { return print("parameter is wrong") }
        if shipId == -2 {
            excludeShipsWithoutFlagShip(deckNumber: deckNumber)
            notify(type: .removeAllWithoutFlagship)
            return
        }
        let store = ServerDataStore.oneTimeEditor()
        let decks = store.decksSortedById()
        let shipIds = decks.flatMap { (deck) -> [Int] in
            return (0..<6).map {
                if let res = deck.value(forKey: "ship_\($0)") as? Int {
                    return res
                }
                return -1
            }
        }
        
        // すでに編成されているか？ どこに？
        let alreadyInFleet = shipIds.contains(shipId)
        let index = alreadyInFleet ? shipIds.index(of: shipId) : nil
        let shipDeckNumber = index.map { $0 / 6 } ?? -1
        let shipDeckIndex = index.map { $0 % 6 } ?? -1
        
        // 配置しようとする位置に今配置されている艦娘
        let currentIndex = (deckNumber - 1) * 6 + shipIndex
        guard 0..<shipIds.count ~= currentIndex
            else { return }
        let replaceShipId = shipIds[currentIndex]
        
        // 艦隊に配備
        guard 0..<decks.count ~= (deckNumber - 1)
            else { return }
        let deck = decks[deckNumber - 1]
        deck.setValue(shipId as NSNumber, forKey: "ship_\(shipIndex)")
        
        // 入れ替え
        if alreadyInFleet,
            shipId != -1,
            0..<decks.count ~= shipDeckNumber
        {
            let aDeck = decks[shipDeckNumber]
            aDeck.setValue(replaceShipId, forKey: "ship_\(shipDeckIndex)")
        }
        
        packFleet(store: store)
        
        // Notify
        if alreadyInFleet && shipId == -1 {
            notify(type: .remove,
                   fleetNumber: deckNumber,
                   position: shipIndex,
                   shipID: replaceShipId)
        }
        else if alreadyInFleet {
            notify(type: .replace,
                   fleetNumber: deckNumber,
                   position: shipIndex,
                   shipID: shipId,
                   replaceFleetNumber: shipDeckNumber + 1,
                   replacePosition: shipDeckIndex,
                   replaceShipID: replaceShipId)
        }
        else {
            notify(type: .append,
                   fleetNumber: deckNumber,
                   position: shipIndex,
                   shipID: shipId)
        }
    }
    
    private func excludeShipsWithoutFlagShip(deckNumber: Int) {
        let store = ServerDataStore.oneTimeEditor()
        guard let deck = store.deck(byId: deckNumber)
            else { return print("Deck not found") }
        (1..<6).forEach {
            deck.setValue(-1 as NSNumber, forKey: "ship_\($0)")
        }
    }
    
    private func packFleet(store: ServerDataStore) {
        store.decksSortedById()
            .forEach { (deck) in
                var needsPack = false
                (0..<6).forEach {
                    let shipId = deck.value(forKey: "ship_\($0)") as? Int
                    if (shipId == nil || shipId! == -1) && !needsPack {
                        needsPack = true
                        return
                    }
                    if needsPack {
                        deck.setValue(shipId! as NSNumber, forKey: "ship_\($0 - 1)")
                        if $0 == 5 {
                            deck.setValue(-1 as NSNumber, forKey: "ship_5")
                        }
                    }
                }
        }
    }
    
    private func notify(type: ChangeHenseiType,
                        fleetNumber: Int = 0,
                        position: Int = 0,
                        shipID: Int = 0,
                        replaceFleetNumber: Int? = nil,
                        replacePosition: Int? = nil,
                        replaceShipID: Int? = nil) {
        let userInfo = HenseiDidChangeUserInfo(type: type,
                                               fleetNumber: fleetNumber,
                                               position: position,
                                               shipID: shipID,
                                               replaceFleetNumber: replaceFleetNumber,
                                               replacePosition: replacePosition,
                                               replaceShipID: replaceShipID)
        NotificationCenter.default
            .post(name: .HenseiDidChange,
                  object: self,
                  userInfo: [ChangeHenseiCommand.userInfoKey: userInfo])
    }
}
