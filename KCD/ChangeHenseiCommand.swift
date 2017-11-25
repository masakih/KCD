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
            let shipIndex = parameter["api_ship_idx"].int else {
                
                return Logger.shared.log("parameter is wrong")
        }
        
        if shipId == -1 {
            
            guard let ship = removeShip(deckNumber: deckNumber, index: shipIndex) else { return }
            notify(type: .remove, fleetNumber: deckNumber, position: shipIndex, shipID: ship.id)
            return
        }
        
        if shipId == -2 {
            
            excludeShipsWithoutFlagShip(deckNumber: deckNumber)
            notify(type: .removeAllWithoutFlagship)
            return
        }
        
        guard case 0..<Deck.maxShipCount = shipIndex else { return }
        
        let store = ServerDataStore.oneTimeEditor()
        guard let deck = store.deck(by: deckNumber) else { return }
        
        // すでに編成されているか？ どこに？
        let (shipDeckNumber, shipDeckIndex) = position(of: shipId)
        
        // 配置しようとする位置に今配置されている艦娘
        let replaceShipId = deck[shipIndex]?.id
        
        // 艦隊に配備
        deck.setShip(id: shipId, for: shipIndex)
        
        // 入れ替え
        if shipDeckNumber != nil {
            
            let shipDeck = store.deck(by: shipDeckNumber!)
            shipDeck?.setShip(id: replaceShipId ?? -1, for: shipDeckIndex)
            shipDeck.map { packFleet(store: store, deck: $0) }
        }
        
        packFleet(store: store, deck: deck)
        
        // Notify
        if shipDeckNumber != nil {
            
            notify(type: .replace,
                   fleetNumber: deckNumber,
                   position: shipIndex,
                   shipID: shipId,
                   replaceFleetNumber: shipDeckNumber!,
                   replacePosition: shipDeckIndex,
                   replaceShipID: replaceShipId)
            
        } else {
            
            notify(type: .append, fleetNumber: deckNumber, position: shipIndex, shipID: shipId)
        }
    }
    
    private func position(of shipId: Int) -> (deckNumber: Int?, shipId: Int) {
        
        return ServerDataStore.default
            .decksSortedById()
            .lazy
            .enumerated()
            .map { (idx, deck) -> (Int, [Ship]) in (idx + 1, deck[0..<Deck.maxShipCount]) }
            .filter { $0.1.contains { $0.id == shipId } }
            .map { (deck, ships) in (deck, ships.index(where: { $0.id == shipId })!) }
            .first ?? (nil, -1)
    }
    
    private func removeShip(deckNumber: Int, index: Int) -> Ship? {
        
        let store = ServerDataStore.oneTimeEditor()
        
        guard let deck = store.deck(by: deckNumber) else { return Logger.shared.log("Deck not found", value: nil) }
        
        let shipId = deck[index]?.id ?? -1
        deck.setShip(id: -1, for: index)
        
        packFleet(store: store, deck: deck)
        
        return ServerDataStore.default.ship(by: shipId)
    }
    
    private func excludeShipsWithoutFlagShip(deckNumber: Int) {
        
        let store = ServerDataStore.oneTimeEditor()
        
        guard let deck = store.deck(by: deckNumber) else {
            
            return Logger.shared.log("Deck not found")
        }
        
        (1..<Deck.maxShipCount).forEach { deck.setShip(id: -1, for: $0) }
    }
    
    private func packFleet(store: ServerDataStore, deck: Deck) {
        
        func set(_ ships: [Ship], at index: Int, in deck: Deck) {
            
            guard index < Deck.maxShipCount else { return }
            
            deck.setShip(id: ships.first?.id ?? -1, for: index)
            
            let newShips = ships.isEmpty ? [] : Array(ships[1...])
            
            set(newShips, at: index + 1, in: deck)
        }
        
        set(deck[0..<Deck.maxShipCount], at: 0, in: deck)
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
