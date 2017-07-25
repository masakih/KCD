//
//  DeckBuilder.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/07/14.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class DeckBuilder {
    
    private let structure: DeckBuilderStructure
    
    init() {
        
        structure = DeckBuilder.build()
    }
    
    func openDeckBuilder() {
        
        // use for encodeURIComponent() of Javascript
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-_.!~*'()")
        
        let desc = structure.deckDescription
        
        Debug.excute(level: .debug) { print(desc as Any) }
        
        let ss = "http://kancolle-calc.net/deckbuilder.html?predeck="
        
        if let param = desc.addingPercentEncoding(withAllowedCharacters: characterSet),
            let url = URL(string: ss + param) {
            
            NSWorkspace.shared().open(url)
        }
    }
    
    private static func build() -> DeckBuilderStructure {
        
        let fleets = ServerDataStore.default
            .decksSortedById()
            .map(buildDeck)
        let hqLv = ServerDataStore.default.basic()?.level
        
        return DeckBuilderStructure(hqLv: hqLv, fleets: fleets)
    }
    
    private static func buildDeck(deck: Deck) -> DBFleet {
        
        let ships = deck[0...5].map(buildShip)
        
        return DBFleet(ships: ships)
    }
    
    private static func buildShip(ship: Ship) -> DBShip {
        
        let items = ship
            .equippedItem
            .flatMap { $0 as? SlotItem }
            .flatMap(buildItem)
        let exItem = ship.extraItem.map(buildItem)
        
        return DBShip(id: ship.master_ship.id,
                      lv: ship.lv,
                      luck: ship.lucky_0,
                      items: items,
                      exItem: exItem)
    }
    
    private static func buildItem(item: SlotItem) -> DBItem {
        
        return DBItem(id: item.master_slotItem.id,
                      lv: item.level != 0 ? item.level : nil,
                      aLv: item.alv != 0 ? item.alv : nil)
    }
}
