//
//  DeckBuilderStructure.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/07/14.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

protocol DeckBuilderDescriptable {
    
    var deckDescription: String { get }
}

struct DeckBuilderStructure {
    
    let version: Int = 4
    let hqLv: Int?
    let fleets: [DBFleet]
}

struct DBFleet {
    
    let ships: [DBShip]
}

struct DBShip {
    
    let id: Int
    let lv: Int
    let luck: Int
    let items: [DBItem]
    let exItem: DBItem?
}

struct DBItem {
    
    let id: Int
    let lv: Int?
    let aLv: Int?
}

extension DeckBuilderStructure: DeckBuilderDescriptable {
    
    var deckDescription: String {
        
        let verStr = "\"version\":\(version)"
        let fleetStr = zip(1..., fleets)
            .map { "\"f\($0.0)\":{\($0.1.deckDescription)}" }
            .joined(separator: ",")
        let hqLvStr = hqLv.map { "\"hqlv\":\($0)" }
        
        let join = [verStr, fleetStr, hqLvStr]
            .compactMap { $0 }
            .joined(separator: ",")
        
        return "{\(join)}"
    }
}

extension DBFleet: DeckBuilderDescriptable {
    
    var deckDescription: String {
        
        return zip(1..., ships)
            .map { "\"s\($0.0)\":{\($0.1.deckDescription)}" }
            .joined(separator: ",")
    }
}

extension DBShip: DeckBuilderDescriptable {
    
    var deckDescription: String {
        
        return "\"id\":\"\(id)\",\"lv\":\(lv),\"luck\":\(luck),\"items\":{\(fullItemDesc)}"
    }
    
    private var fullItemDesc: String {
        
        switch (items, exDesc) {
        case let (items, ex?) where items.isEmpty: return ex
        case let (_, ex?): return "\(itemsDesc),\(ex)"
        default: return itemsDesc
        }
    }
    
    private var itemsDesc: String {
        
        return zip(1..., items)
            .map { "\"i\($0.0)\":{\($0.1.deckDescription)}" }
            .joined(separator: ",")
    }
    
    private var exDesc: String? {
        
        return exItem.map { "\"ix\":{\($0.deckDescription)}" }
    }
}

extension DBItem: DeckBuilderDescriptable {
    
    var deckDescription: String {
        
        switch (lv, aLv) {
        case let (lv?, aLv?): return "\"id\":\(id),\"rf\":\(lv),\"mas\":\(aLv)"
        case let (lv?, _): return "\"id\":\(id),\"rf\":\(lv)"
        case let (_, aLv?): return "\"id\":\(id),\"mas\":\(aLv)"
        default: return "\"id\":\(id)"
        }
    }
}
