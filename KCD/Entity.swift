//
//  Entity.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import CoreData

struct Entity<T: NSManagedObject> {
    
    let name: String
    
    init(name: String, type: T.Type) {
        
        self.name = name
    }
}

protocol EntityProvider {
    
    associatedtype ObjectType: NSManagedObject = Self
    
    static var entityName: String { get }
    static var entity: Entity<ObjectType> { get }
}

extension EntityProvider {
    
    static var entity: Entity<ObjectType> {
        
        return Entity(name: entityName, type: ObjectType.self)
    }
}

// MARK: - Implementations
extension NSManagedObject {
    
    class var entityName: String { return String(describing: self) }
}

// MARK: - KCD model
extension AirBase: EntityProvider {}
extension AirBasePlaneInfo: EntityProvider {}
extension Basic: EntityProvider {}
extension Deck: EntityProvider {}
extension KenzoDock: EntityProvider {}
extension MasterFurniture: EntityProvider {}
extension MasterMapArea: EntityProvider {}
extension MasterMapInfo: EntityProvider {}
extension MasterMission: EntityProvider {}
extension MasterShip: EntityProvider {}
extension MasterSlotItem: EntityProvider {}
extension MasterSType: EntityProvider {}
extension MasterSlotItemEquipType: EntityProvider {}
extension MasterUseItem: EntityProvider {}
extension Material: EntityProvider {}
extension NyukyoDock: EntityProvider {}
extension Ship: EntityProvider {}
extension SlotItem: EntityProvider {}
extension Quest: EntityProvider {}

// MARK: - LocalData model
extension DropShipHistory: EntityProvider {}
extension HiddenDropShipHistory: EntityProvider {}
extension KaihatuHistory: EntityProvider {}
extension KenzoHistory: EntityProvider {}
extension KenzoMark: EntityProvider {}

// MARK: - Temporay model
extension Battle: EntityProvider {}
extension Damage: EntityProvider {}
extension GuardEscaped: EntityProvider {}

// MARK: - Bookmark model
extension Bookmark: EntityProvider {}

// MARK: - ResourceHistory model
extension Resource: EntityProvider {}
