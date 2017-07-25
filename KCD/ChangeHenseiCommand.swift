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

final class HenseiDidChangeUserInfo: NSObject {
    
    let type: ChangeHenseiType
    
    let fleetNumber: Int
    let position: Int
    let shipID: Int
    
    let replaceFleetNumber: Int?
    let replacePosition: Int?
    let replaceShipID: Int?
    
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

final class ChangeHenseiCommand: JSONCommand {
    
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
        
        guard let deckNumber = parameter["api_id"].int,
            let shipId = parameter["api_ship_id"].int,
            let shipIndex = parameter["api_ship_idx"].int
            else { return print("parameter is wrong") }
        
        if shipId == -2 {
            
            excludeShipsWithoutFlagShip(deckNumber: deckNumber)
            notify(type: .removeAllWithoutFlagship)
            
            return
        }
        
        let store = ServerDataStore.oneTimeEditor()
        let decks = store.decksSortedById()
        let shipIds = decks.flatMap { deck in (0..<6).map { deck.shipId(of: $0) ?? -1 } }
        
        // すでに編成されているか？ どこに？
        let currentIndex = shipIds.index(of: shipId)
        let shipDeckNumber = currentIndex.map { $0 / 6 } ?? -1
        let shipDeckIndex = currentIndex.map { $0 % 6 } ?? -1
        
        // 配置しようとする位置に今配置されている艦娘
        let replaceIndex = (deckNumber - 1) * 6 + shipIndex
        
        guard case 0..<shipIds.count = replaceIndex
            else { return }
        
        let replaceShipId = shipIds[replaceIndex]
        
        // 艦隊に配備
        guard case 0..<decks.count = (deckNumber - 1)
            else { return }
        
        decks[deckNumber - 1].setShip(id: shipId, for: shipIndex)
        
        // 入れ替え
        if currentIndex != nil, shipId != -1, case 0..<decks.count = shipDeckNumber {
            
            decks[shipDeckNumber].setShip(id: replaceShipId, for: shipDeckIndex)
        }
        
        packFleet(store: store)
        
        // Notify
        if currentIndex != nil, shipId == -1 {
            
            notify(type: .remove,
                   fleetNumber: deckNumber,
                   position: shipIndex,
                   shipID: replaceShipId)
            
        } else if currentIndex != nil {
            
            notify(type: .replace,
                   fleetNumber: deckNumber,
                   position: shipIndex,
                   shipID: shipId,
                   replaceFleetNumber: shipDeckNumber + 1,
                   replacePosition: shipDeckIndex,
                   replaceShipID: replaceShipId)
            
        } else {
            
            notify(type: .append,
                   fleetNumber: deckNumber,
                   position: shipIndex,
                   shipID: shipId)
        }
    }
    
    private func excludeShipsWithoutFlagShip(deckNumber: Int) {
        
        let store = ServerDataStore.oneTimeEditor()
        
        guard let deck = store.deck(by: deckNumber)
            else { return print("Deck not found") }
        
        (1..<6).forEach { deck.setShip(id: -1, for: $0) }
    }
    
    private func packFleet(store: ServerDataStore) {
        
        store.decksSortedById()
            .forEach { deck in
                
                var needsPack = false
                (0..<6).forEach {
                    
                    let shipId = deck.shipId(of: $0)
                    // TODO: うまいことする　強制アンラップを消す
                    if (shipId == nil || shipId! == -1), !needsPack {
                        
                        needsPack = true
                        
                        return
                    }
                    if needsPack {
                        
                        deck.setShip(id: shipId!, for: $0 - 1)
                        if $0 == 5 { deck.setShip(id: -1, for: 5) }
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
