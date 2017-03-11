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

extension KCAirBase: EntityProvider {
    override class var entityName: String { return "AirBase" }
}
extension KCAirBasePlaneInfo: EntityProvider {
    override class var entityName: String { return "AirBasePlaneInfo" }
}
extension KCBasic: EntityProvider {
    override class var entityName: String { return "Basic" }
}
extension KCDeck: EntityProvider {
    override class var entityName: String { return "Deck" }
}
extension KCKenzoDock: EntityProvider {
    override class var entityName: String { return "KenzoDock" }
}
extension MasterFurniture: EntityProvider {
    override class var entityName: String { return "MasterFurniture" }
}
extension KCMasterMapArea: EntityProvider {
    override class var entityName: String { return "MasterMapArea" }
}
extension KCMasterMapInfo: EntityProvider {
    override class var entityName: String { return "MasterMapInfo" }
}
extension KCMasterMission: EntityProvider {
    override class var entityName: String { return "MasterMission" }
}
extension KCMasterShipObject: EntityProvider {
    override class var entityName: String { return "MasterShip" }
}
extension KCMasterSlotItemObject: EntityProvider {
    override class var entityName: String { return "MasterSlotItem" }
}
extension KCMasterSType: EntityProvider {
    override class var entityName: String { return "MasterSType" }
}
extension KCMasterSlotItemEquipTypeObject: EntityProvider {
    override class var entityName: String { return "MasterSlotItemEquipType" }
}
extension MasterUseItem: EntityProvider {
    override class var entityName: String { return "MasterUseItem" }
}
extension KCMaterial: EntityProvider {
    override class var entityName: String { return "Material" }
}
extension KCNyukyoDock: EntityProvider {
    override class var entityName: String { return "NyukyoDock" }
}
extension KCShipObject: EntityProvider {
    override class var entityName: String { return "Ship" }
}
extension KCSlotItemObject: EntityProvider {
    override class var entityName: String { return "SlotItem" }
}
extension KCQuest: EntityProvider {
    override class var entityName: String { return "Quest" }
}

extension ServerDataStore {
    func airBases() -> [KCAirBase] {
        guard let airbase = try? objects(with: KCAirBase.entity)
            else { return [] }
        return airbase
    }
    func airBase(area: Int, base: Int) -> KCAirBase? {
        let p = NSPredicate(format: "area_id == %ld AND rid == %ld", area, base)
        guard let airBases = try? objects(with: KCAirBase.entity, predicate: p)
            else { return nil }
        return airBases.first
    }
    func createAirBasePlaneInfo() -> KCAirBasePlaneInfo? {
        return insertNewObject(for: KCAirBasePlaneInfo.entity)
    }
    
    func basic() -> KCBasic? {
        guard let basics = try? objects(with: KCBasic.entity)
            else { return nil }
        return basics.first
    }
    func createBasic() -> KCBasic? {
        return insertNewObject(for: KCBasic.entity)
    }
    
    func decksSortedById() -> [KCDeck] {
        let sortDec = NSSortDescriptor(key: "id", ascending: true)
        guard let decks = try? objects(with: KCDeck.entity, sortDescriptors: [sortDec])
            else { return [] }
        return decks
    }
    func deck(byId id: Int) -> KCDeck? {
        let p = NSPredicate(format: "id = %ld", id)
        guard let decks = try? objects(with: KCDeck.entity, predicate: p)
            else { return nil }
        return decks.first
    }
    
    func kenzoDock(byDockId dockId: Int) -> KCKenzoDock? {
        let dockPredicate = NSPredicate(format: "id = %ld", dockId)
        guard let kenzoDocks = try? objects(with: KCKenzoDock.entity, predicate: dockPredicate)
            else { return nil }
        return kenzoDocks.first
    }
    
    func mapArea(byId id: Int) -> KCMasterMapArea? {
        let predicate = NSPredicate(format: "id = %ld", id)
        guard let mapAreas = try? objects(with: KCMasterMapArea.entity, predicate: predicate)
            else { return nil }
        return mapAreas.first
    }
    
    func mapInfo(area: Int, no: Int) -> KCMasterMapInfo? {
        let predicate = NSPredicate(format: "maparea_id = %ld AND %K = %ld", area, "no", no)
        guard let mapInfos = try? objects(with: KCMasterMapInfo.entity, predicate: predicate)
            else { return nil }
        return mapInfos.first
    }
    
    func masterMission(by id: Int) -> KCMasterMission? {
        let p = NSPredicate(format: "id = %ld", id)
        guard let missions = try? objects(with: KCMasterMission.entity, predicate: p)
            else { return nil }
        return missions.first
    }
    
    func masterShips() -> [KCMasterShipObject] {
        guard let ships = try? objects(with: KCMasterShipObject.entity)
            else { return [] }
        return ships
    }
    func sortedMasterShipsById() -> [KCMasterShipObject] {
        let sortDesc = NSSortDescriptor(key: "id", ascending: true)
        guard let ships = try? objects(with: KCMasterShipObject.entity, sortDescriptors: [sortDesc])
            else { return [] }
        return ships
    }
    func masterShip(byId id: Int) -> KCMasterShipObject? {
        let p = NSPredicate(format: "id = %ld", id)
        guard let ships = try? objects(with: KCMasterShipObject.entity, predicate: p)
            else { return nil }
        return ships.first
    }
    
    func sortedMasterSlotItemsById() -> [KCMasterSlotItemObject] {
        let sortDesc = NSSortDescriptor(key: "id", ascending: true)
        guard let masterSlotItems = try? objects(with: KCMasterSlotItemObject.entity, sortDescriptors: [sortDesc])
            else { return [] }
        return masterSlotItems
    }
    func masterSlotItems() -> [KCMasterSlotItemObject] {
        guard let masterSlotItems = try? objects(with: KCMasterSlotItemObject.entity)
            else { return [] }
        return masterSlotItems
    }
    func masterSlotItem(by id: Int) -> KCMasterSlotItemObject? {
        let p = NSPredicate(format: "id = %ld", id)
        guard let masterSlotItems = try? objects(with: KCMasterSlotItemObject.entity, predicate: p)
            else { return nil }
        return masterSlotItems.first
    }
    
    func masterSlotItemEquipType(by id: Int) -> KCMasterSlotItemEquipTypeObject? {
        let predicate = NSPredicate(format: "id = %ld", id)
        guard let types = try? objects(with: KCMasterSlotItemEquipTypeObject.entity, predicate: predicate)
            else { return nil }
        return types.first
    }
    
    func masterSTypes() -> [KCMasterSType] {
        guard let masterSTypes = try? objects(with: KCMasterSType.entity)
            else { return [] }
        return masterSTypes
    }
    func sortedMasterSTypesById() -> [KCMasterSType] {
        let sortDesc = NSSortDescriptor(key: "id", ascending: true)
        guard let masterSTypes = try? objects(with: KCMasterSType.entity, sortDescriptors: [sortDesc])
            else { return [] }
        return masterSTypes
    }
    
    func material() -> KCMaterial? {
        guard let materials = try? objects(with: KCMaterial.entity)
            else { return nil }
        return materials.first
    }
    func createMaterial() -> KCMaterial? {
        return insertNewObject(for: KCMaterial.entity)
    }
    
    func nyukyoDock(by id: Int) -> KCNyukyoDock? {
        let p = NSPredicate(format: "id = %ld", id)
        guard let ndocks = try? objects(with: KCNyukyoDock.entity, predicate: p)
            else { return nil }
        return ndocks.first
    }
    
    func ships(byDeckId deckId: Int) -> [KCShipObject] {
        let predicate = NSPredicate(format: "id = %d", deckId)
        guard let decks = try? objects(with: KCDeck.entity, predicate: predicate),
            let deck = decks.first
            else { return [] }
        return (0..<6).flatMap { deck[$0] }
    }
    func ship(byId shipId: Int) -> KCShipObject? {
        if shipId < 1 { return nil }
        let predicate = NSPredicate(format: "id = %d", shipId)
        guard let ships = try? objects(with: KCShipObject.entity, predicate: predicate)
            else { return nil }
        return ships.first
    }
    func ships(byId shipId: Int) -> [KCShipObject] {
        let predicate = NSPredicate(format: "id = %d", shipId)
        guard let ships = try? objects(with: KCShipObject.entity, predicate: predicate)
            else { return [] }
        return ships
    }
    func ships(exclude shipIds: [Int]) -> [KCShipObject] {
        let predicate = NSPredicate(format: "NOT id IN %@", shipIds)
        guard let ships = try? objects(with: KCShipObject.entity, predicate: predicate)
            else { return [] }
        return ships
    }
    func shipsInFleet() -> [KCShipObject] {
        let predicate = NSPredicate(format: "NOT fleet = 0")
        guard let ships = try? objects(with: KCShipObject.entity, predicate: predicate)
            else { return [] }
        return ships
    }
    func createShip() -> KCShipObject? {
        return insertNewObject(for: KCShipObject.entity)
    }
    
    func masterSlotItemID(bySlotItemId slotItemId: Int) -> Int {
        if slotItemId < 1 { return 0 }
        let predicate = NSPredicate(format: "id = %d", argumentArray: [slotItemId])
        guard let slotItems = try? objects(with: KCSlotItemObject.entity, predicate: predicate),
            let slotItem = slotItems.first
            else { return 0 }
        return slotItem.master_slotItem.id
    }
    
    func slotItem(byId itemId: Int) -> KCSlotItemObject? {
        let p = NSPredicate(format: "id = %ld", itemId)
        guard let slotItems = try? objects(with: KCSlotItemObject.entity, predicate: p)
            else { return nil }
        return slotItems.first
    }
    func sortedSlotItemsById() -> [KCSlotItemObject] {
        let sortDesc = NSSortDescriptor(key: "id", ascending: true)
        guard let slotItems = try? objects(with: KCSlotItemObject.entity, sortDescriptors: [sortDesc])
            else { return [] }
        return slotItems
    }
    func slotItems() -> [KCSlotItemObject] {
        guard let slotItems = try? objects(with: KCSlotItemObject.entity)
            else { return [] }
        return slotItems
    }
    func slotItems(in itemIds: [Int]) -> [KCSlotItemObject] {
        let predicate = NSPredicate(format: "id IN %@", itemIds)
        guard let slotItems = try? objects(with: KCSlotItemObject.entity, predicate: predicate)
            else { return [] }
        return slotItems
    }
    func slotItems(exclude itemIds: [Int]) -> [KCSlotItemObject] {
        let predicate = NSPredicate(format: "NOT id IN %@", itemIds)
        guard let slotItems = try? objects(with: KCSlotItemObject.entity, predicate: predicate)
            else { return [] }
        return slotItems
    }
    func createSlotItem() -> KCSlotItemObject? {
        return insertNewObject(for: KCSlotItemObject.entity)
    }
    
    func quests() -> [KCQuest] {
        guard let quests = try? objects(with: KCQuest.entity)
            else { return [] }
        return quests
    }
    func quest(by no: Int) -> KCQuest? {
        let p = NSPredicate(format: "%K = %ld", "no", no)
        guard let quests = try? objects(with: KCQuest.entity, predicate: p)
            else { return nil }
        return quests.first
    }
    func quests(in range: CountableClosedRange<Int>) -> [KCQuest] {
        let p = NSPredicate(format: "%K In %@", "no", range.map {$0})
        guard let quests = try? objects(with: KCQuest.entity, predicate: p)
            else { return [] }
        return quests
    }
    func sortedQuestByNo() -> [KCQuest] {
        let sortDesc = NSSortDescriptor(key: "no", ascending: true)
        guard let quests = try? objects(with: KCQuest.entity, sortDescriptors: [sortDesc])
            else { return [] }
        return quests
    }
    func createQuest() -> KCQuest? {
        return insertNewObject(for: KCQuest.entity)
    }
}
