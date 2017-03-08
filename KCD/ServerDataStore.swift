//
//  ServerDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/07.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension CoreDataIntormation {
    static let kcd = CoreDataIntormation(
        modelName: "KCD",
        storeFileName: "KCD.storedata",
        storeOptions:[NSMigratePersistentStoresAutomaticallyOption: true,
                      NSInferMappingModelAutomaticallyOption: true],
        storeType: NSSQLiteStoreType,
        deleteAndRetry: true
    )
}
extension CoreDataCore {
    static let kcd = CoreDataCore(.kcd)
}
extension Entity {
    static let airBase = Entity(name: "AirBase")
    static let airBasePlaneInfo = Entity(name: "AirBasePlaneInfo")
    static let basic = Entity(name: "Basic")
    static let deck = Entity(name: "Deck")
    static let kenzoDock = Entity(name: "KenzoDock")
    static let masterFurniture = Entity(name: "MasterFurniture")
    static let masterMapArea = Entity(name: "MasterMapArea")
    static let masterMapInfo = Entity(name: "MasterMapInfo")
    static let masterMission = Entity(name: "MasterMission")
    static let masterShip = Entity(name: "MasterShip")
    static let masterSlotItem = Entity(name: "MasterSlotItem")
    static let masterSlotItemEquipType = Entity(name: "MasterSlotItemEquipType")
    static let masterSType = Entity(name: "MasterSType")
    static let masterUseItem = Entity(name: "MasterUseItem")
    static let material = Entity(name: "Material")
    static let nyukyoDock = Entity(name: "NyukyoDock")
    static let ship = Entity(name: "Ship")
    static let slotItem = Entity(name: "SlotItem")
    static let quest = Entity(name: "Quest")
}

class ServerDataStore: CoreDataAccessor, CoreDataManager {
    static var `default` = ServerDataStore(type: .reader)
    class func oneTimeEditor() -> ServerDataStore {
        return ServerDataStore(type: .editor)
    }
        
    required init(type: CoreDataManagerType) {
        managedObjectContext =
            type == .reader ? core.parentManagedObjectContext
            : core.editorManagedObjectContext()
    }
    deinit {
        saveActionCore()
    }
    
    let core = CoreDataCore.kcd
    var managedObjectContext: NSManagedObjectContext
}

extension ServerDataStore {
    func airBases() -> [KCAirBase] {
        guard let res = try? objects(with: .airBase),
            let airbase = res as? [KCAirBase]
            else { return [] }
        return airbase
    }
    func airBase(area: Int, base: Int) -> KCAirBase? {
        let p = NSPredicate(format: "area_id == %ld AND rid == %ld", area, base)
        guard let a = try? objects(with: .airBase, predicate: p),
            let airBases = a as? [KCAirBase],
            let airBase = airBases.first
            else { return nil }
        return airBase
    }
    func createAirBasePlaneInfo() -> KCAirBasePlaneInfo? {
        return insertNewObject(for: .airBasePlaneInfo) as? KCAirBasePlaneInfo
    }
    
    func basic() -> KCBasic? {
        guard let b = try? objects(with: .basic),
            let basics = b as? [KCBasic],
            let basic = basics.first
            else { return nil }
        return basic
    }
    func createBasic() -> KCBasic? {
        return insertNewObject(for: .basic) as? KCBasic
    }
    
    func decksSortedById() -> [KCDeck] {
        let sortDec = NSSortDescriptor(key: "id", ascending: true)
        guard let d = try? objects(with: .deck, sortDescriptors: [sortDec]),
            let decks = d as? [KCDeck]
            else { return [] }
        return decks
    }
    func deck(byId id: Int) -> KCDeck? {
        let p = NSPredicate(format: "id = %ld", id)
        guard let d = try? objects(with: .deck, predicate: p),
            let decks = d as? [KCDeck],
            let deck = decks.first
            else { return nil }
        return deck
    }
    
    func kenzoDock(byDockId dockId: Int) -> KCKenzoDock? {
        let dockPredicate = NSPredicate(format: "id = %ld", dockId)
        guard let k = try? objects(with: .kenzoDock, predicate: dockPredicate),
            let kenzoDocks = k as? [KCKenzoDock],
            let kenzoDock = kenzoDocks.first
            else { return nil }
        return kenzoDock
    }
    
    func mapArea(byId id: Int) -> KCMasterMapArea? {
        let predicate = NSPredicate(format: "id = %ld", id)
        guard let a = try? objects(with: .masterMapArea, predicate: predicate),
            let mapAreas = a as? [KCMasterMapArea],
            let mapArea = mapAreas.first
            else { return nil }
        return mapArea
    }
    
    func mapInfo(area: Int, no: Int) -> KCMasterMapInfo? {
        let predicate = NSPredicate(format: "maparea_id = %ld AND %K = %ld", area, "no", no)
        guard let m = try? objects(with: .masterMapInfo, predicate: predicate),
            let mapInfos = m as? [KCMasterMapInfo],
            let mapInfo = mapInfos.first
            else { return nil }
        
        return mapInfo
    }
    
    func masterMission(by id: Int) -> KCMasterMission? {
        let p = NSPredicate(format: "id = %ld", id)
        guard let ss = try? objects(with: .masterMission, predicate: p),
            let missions = ss as? [KCMasterMission],
            let mission = missions.first
            else { return nil }
        return mission
    }
    
    func masterShips() -> [KCMasterShipObject] {
        guard let s = try? objects(with: .masterShip),
            let ships = s as? [KCMasterShipObject]
            else { return [] }
        return ships
    }
    func sortedMasterShipsById() -> [KCMasterShipObject] {
        let sortDesc = NSSortDescriptor(key: "id", ascending: true)
        guard let s = try? objects(with: .masterShip, sortDescriptors: [sortDesc]),
            let ships = s as? [KCMasterShipObject]
            else { return [] }
        return ships
    }
    func masterShip(byId id: Int) -> KCMasterShipObject? {
        let p = NSPredicate(format: "id = %ld", id)
        guard let s = try? objects(with: .masterShip, predicate: p),
            let ships = s as? [KCMasterShipObject],
            let ship = ships.first
            else { return nil }
        return ship
    }
    
    func sortedMasterSlotItemsById() -> [KCMasterSlotItemObject] {
        let sortDesc = NSSortDescriptor(key: "id", ascending: true)
        guard let ms = try? objects(with: .masterSlotItem, sortDescriptors: [sortDesc]),
            let masterSlotItems = ms as? [KCMasterSlotItemObject]
            else { return [] }
        return masterSlotItems
    }
    func masterSlotItems() -> [KCMasterSlotItemObject] {
        guard let ms = try? objects(with: .masterSlotItem),
            let masterSlotItems = ms as? [KCMasterSlotItemObject]
            else { return [] }
        return masterSlotItems
    }
    func masterSlotItem(by id: Int) -> KCMasterSlotItemObject? {
        let p = NSPredicate(format: "id = %ld", id)
        guard let ma = try? objects(with: .masterSlotItem, predicate: p),
            let masterSlotItems = ma as? [KCMasterSlotItemObject],
            let masterSlotItem = masterSlotItems.first
            else { return nil }
        return masterSlotItem
    }
    
    func masterSlotItemEquipType(by id: Int) -> KCMasterSlotItemEquipTypeObject? {
        let predicate = NSPredicate(format: "id = %ld", id)
        guard let a = try? objects(with: .masterSlotItemEquipType, predicate: predicate),
            let types = a as? [KCMasterSlotItemEquipTypeObject],
            let type = types.first
            else { return nil }
        return type
    }
    
    func masterSTypes() -> [KCMasterSType] {
        guard let ms = try? objects(with: .masterSType),
            let masterSTypes = ms as? [KCMasterSType]
            else {
                print("MaserShipCommand: MasterSType is not found")
                return []
        }
        return masterSTypes
    }
    func sortedMasterSTypesById() -> [KCMasterSType] {
        let sortDesc = NSSortDescriptor(key: "id", ascending: true)
        guard let ms = try? objects(with: .masterSType, sortDescriptors: [sortDesc]),
            let masterSTypes = ms as? [KCMasterSType]
            else {
                print("MaserShipCommand: MasterSType is not found")
                return []
        }
        return masterSTypes
    }
    
    func material() -> KCMaterial? {
        guard let m = try? objects(with: .material),
            let materials = m as? [KCMaterial],
            let material = materials.first
            else { return nil }
        return material
    }
    func createMaterial() -> KCMaterial? {
        return insertNewObject(for: .material) as? KCMaterial
    }
    
    func nyukyoDock(by id: Int) -> KCNyukyoDock? {
        let p = NSPredicate(format: "id = %ld", id)
        guard let d = try? objects(with: .nyukyoDock, predicate: p),
            let ndocks = d as? [KCNyukyoDock],
            let ndock = ndocks.first
            else { return nil }
        return ndock
    }
    
    func ships(byDeckId deckId: Int) -> [KCShipObject] {
        let predicate = NSPredicate(format: "id = %d", deckId)
        guard let d = try? objects(with: .deck, predicate: predicate),
            let decks = d as? [KCDeck],
            let deck = decks.first
            else { return [] }
        return (0..<6).flatMap { deck[$0] }
    }
    func ship(byId shipId: Int) -> KCShipObject? {
        if shipId < 1 { return nil }
        let predicate = NSPredicate(format: "id = %d", shipId)
        guard let s = try? objects(with: .ship, predicate: predicate),
            let ships = s as? [KCShipObject],
            let ship = ships.first
            else { return nil }
        return ship
    }
    func ships(byId shipId: Int) -> [KCShipObject] {
        let predicate = NSPredicate(format: "id = %d", shipId)
        guard let d = try? objects(with: .ship, predicate: predicate),
            let ships = d as? [KCShipObject]
            else { return [] }
        return ships
    }
    func ships(exclude shipIds: [Int]) -> [KCShipObject] {
        let predicate = NSPredicate(format: "NOT id IN %@", shipIds)
        guard let s = try? objects(with: .ship, predicate: predicate),
            let ships = s as? [KCShipObject]
            else { return [] }
        return ships
    }
    func shipsInFleet() -> [KCShipObject] {
        let predicate = NSPredicate(format: "NOT fleet = 0")
        guard let a = try? objects(with: .ship, predicate: predicate),
            let ships = a as? [KCShipObject]
            else { return [] }
        return ships
    }
    func createShip() -> KCShipObject? {
        return insertNewObject(for: .ship) as? KCShipObject
    }
    
    func masterSlotItemID(bySlotItemId slotItemId: Int) -> Int {
        if slotItemId < 1 { return 0 }
        let predicate = NSPredicate(format: "id = %d", argumentArray: [slotItemId])
        guard let s = try? objects(with: .slotItem, predicate: predicate),
            let slotItems = s as? [KCSlotItemObject],
            let slotItem = slotItems.first
            else { return 0 }
        return slotItem.master_slotItem.id
    }
    
    func slotItem(byId itemId: Int) -> KCSlotItemObject? {
        let p = NSPredicate(format: "id = %ld", itemId)
        guard let sl = try? objects(with: .slotItem, predicate: p),
            let slotItems = sl as? [KCSlotItemObject],
            let slotItem = slotItems.first
            else { return nil }
        return slotItem
    }
    func sortedSlotItemsById() -> [KCSlotItemObject] {
        let sortDesc = NSSortDescriptor(key: "id", ascending: true)
        guard let s = try? objects(with: .slotItem, sortDescriptors: [sortDesc]),
            let slotItems = s as? [KCSlotItemObject]
            else { return [] }
        return slotItems
    }
    func slotItems() -> [KCSlotItemObject] {
        guard let s = try? objects(with: .slotItem),
            let slotItems = s as? [KCSlotItemObject]
            else { return [] }
        return slotItems
    }
    func slotItems(in itemIds: [Int]) -> [KCSlotItemObject] {
        let predicate = NSPredicate(format: "id IN %@", itemIds)
        guard let s = try? objects(with: .slotItem, predicate: predicate),
            let slotItems = s as? [KCSlotItemObject]
            else { return [] }
        return slotItems
    }
    func slotItems(exclude itemIds: [Int]) -> [KCSlotItemObject] {
        let predicate = NSPredicate(format: "NOT id IN %@", itemIds)
        guard let s = try? objects(with: .slotItem, predicate: predicate),
            let slotItems = s as? [KCSlotItemObject]
            else { return [] }
        return slotItems
    }
    func createSlotItem() -> KCSlotItemObject? {
        return insertNewObject(for: .slotItem) as? KCSlotItemObject
    }
    
    func quests() -> [KCQuest] {
        return try! objects(with: .quest) as? [KCQuest] ?? []
    }
    func quest(by no: Int) -> KCQuest? {
        let p = NSPredicate(format: "%K = %ld", "no", no)
        guard let qu = try? objects(with: .quest, predicate: p),
            let que = qu as? [KCQuest],
            let quest = que.first
            else { return nil }
        return quest
    }
    func quests(in range: CountableClosedRange<Int>) -> [KCQuest] {
        let p = NSPredicate(format: "%K In %@", "no", range.map {$0})
        guard let qu = try? objects(with: .quest, predicate: p),
            let quests = qu as? [KCQuest]
            else { return [] }
        return quests
    }
    func sortedQuestByNo() -> [KCQuest] {
        let sortDesc = NSSortDescriptor(key: "no", ascending: true)
        guard let qu = try? objects(with: .quest, sortDescriptors: [sortDesc]),
            let quests = qu as? [KCQuest]
            else { return [] }
        return quests
    }
    func createQuest() -> KCQuest? {
        return insertNewObject(for: .quest) as? KCQuest
    }
}
