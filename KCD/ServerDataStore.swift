//
//  ServerDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/07.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension CoreDataConfiguration {
    static let kcd = CoreDataConfiguration("KCD", tryRemake: true)
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
        context = (type == .reader ? core.parentContext : core.editorContext())
    }
    deinit {
        save()
    }
    
    let core = CoreDataCore.kcd
    let context: NSManagedObjectContext
}

extension ServerDataStore {
    func airBases() -> [AirBase] {
        guard let airbase = try? objects(with: AirBase.entity)
            else { return [] }
        return airbase
    }
    func airBase(area: Int, base: Int) -> AirBase? {
        let p = NSPredicate(format: "area_id == %ld AND rid == %ld", area, base)
        guard let airBases = try? objects(with: AirBase.entity, predicate: p)
            else { return nil }
        return airBases.first
    }
    func createAirBasePlaneInfo() -> AirBasePlaneInfo? {
        return insertNewObject(for: AirBasePlaneInfo.entity)
    }
    
    func basic() -> Basic? {
        guard let basics = try? objects(with: Basic.entity)
            else { return nil }
        return basics.first
    }
    func createBasic() -> Basic? {
        return insertNewObject(for: Basic.entity)
    }
    
    func decksSortedById() -> [Deck] {
        let sortDec = NSSortDescriptor(key: "id", ascending: true)
        guard let decks = try? objects(with: Deck.entity, sortDescriptors: [sortDec])
            else { return [] }
        return decks
    }
    func deck(by id: Int) -> Deck? {
        let p = NSPredicate(format: "id = %ld", id)
        guard let decks = try? objects(with: Deck.entity, predicate: p)
            else { return nil }
        return decks.first
    }
    
    func kenzoDock(by dockId: Int) -> KenzoDock? {
        let dockPredicate = NSPredicate(format: "id = %ld", dockId)
        guard let kenzoDocks = try? objects(with: KenzoDock.entity, predicate: dockPredicate)
            else { return nil }
        return kenzoDocks.first
    }
    
    func mapArea(by id: Int) -> MasterMapArea? {
        let predicate = NSPredicate(format: "id = %ld", id)
        guard let mapAreas = try? objects(with: MasterMapArea.entity, predicate: predicate)
            else { return nil }
        return mapAreas.first
    }
    
    func mapInfo(area: Int, no: Int) -> MasterMapInfo? {
        let predicate = NSPredicate(format: "maparea_id = %ld AND %K = %ld", area, "no", no)
        guard let mapInfos = try? objects(with: MasterMapInfo.entity, predicate: predicate)
            else { return nil }
        return mapInfos.first
    }
    
    func masterMission(by id: Int) -> MasterMission? {
        let p = NSPredicate(format: "id = %ld", id)
        guard let missions = try? objects(with: MasterMission.entity, predicate: p)
            else { return nil }
        return missions.first
    }
    
    func masterShips() -> [MasterShip] {
        guard let ships = try? objects(with: MasterShip.entity)
            else { return [] }
        return ships
    }
    func sortedMasterShipsById() -> [MasterShip] {
        let sortDesc = NSSortDescriptor(key: "id", ascending: true)
        guard let ships = try? objects(with: MasterShip.entity, sortDescriptors: [sortDesc])
            else { return [] }
        return ships
    }
    func masterShip(by id: Int) -> MasterShip? {
        let p = NSPredicate(format: "id = %ld", id)
        guard let ships = try? objects(with: MasterShip.entity, predicate: p)
            else { return nil }
        return ships.first
    }
    
    func sortedMasterSlotItemsById() -> [MasterSlotItem] {
        let sortDesc = NSSortDescriptor(key: "id", ascending: true)
        guard let masterSlotItems = try? objects(with: MasterSlotItem.entity, sortDescriptors: [sortDesc])
            else { return [] }
        return masterSlotItems
    }
    func masterSlotItems() -> [MasterSlotItem] {
        guard let masterSlotItems = try? objects(with: MasterSlotItem.entity)
            else { return [] }
        return masterSlotItems
    }
    func masterSlotItem(by id: Int) -> MasterSlotItem? {
        let p = NSPredicate(format: "id = %ld", id)
        guard let masterSlotItems = try? objects(with: MasterSlotItem.entity, predicate: p)
            else { return nil }
        return masterSlotItems.first
    }
    
    func masterSlotItemEquipType(by id: Int) -> MasterSlotItemEquipType? {
        let predicate = NSPredicate(format: "id = %ld", id)
        guard let types = try? objects(with: MasterSlotItemEquipType.entity, predicate: predicate)
            else { return nil }
        return types.first
    }
    
    func masterSTypes() -> [MasterSType] {
        guard let masterSTypes = try? objects(with: MasterSType.entity)
            else { return [] }
        return masterSTypes
    }
    func sortedMasterSTypesById() -> [MasterSType] {
        let sortDesc = NSSortDescriptor(key: "id", ascending: true)
        guard let masterSTypes = try? objects(with: MasterSType.entity, sortDescriptors: [sortDesc])
            else { return [] }
        return masterSTypes
    }
    
    func material() -> Material? {
        guard let materials = try? objects(with: Material.entity)
            else { return nil }
        return materials.first
    }
    func createMaterial() -> Material? {
        return insertNewObject(for: Material.entity)
    }
    
    func nyukyoDock(by id: Int) -> NyukyoDock? {
        let p = NSPredicate(format: "id = %ld", id)
        guard let ndocks = try? objects(with: NyukyoDock.entity, predicate: p)
            else { return nil }
        return ndocks.first
    }
    
    func ships(byDeckId deckId: Int) -> [Ship] {
        let predicate = NSPredicate(format: "id = %d", deckId)
        guard let decks = try? objects(with: Deck.entity, predicate: predicate),
            let deck = decks.first
            else { return [] }
        return (0..<6).flatMap { deck[$0] }
    }
    func ship(by shipId: Int) -> Ship? {
        if shipId < 1 { return nil }
        let predicate = NSPredicate(format: "id = %d", shipId)
        guard let ships = try? objects(with: Ship.entity, predicate: predicate)
            else { return nil }
        return ships.first
    }
    func ships(by shipId: Int) -> [Ship] {
        let predicate = NSPredicate(format: "id = %d", shipId)
        guard let ships = try? objects(with: Ship.entity, predicate: predicate)
            else { return [] }
        return ships
    }
    func ships(exclude shipIds: [Int]) -> [Ship] {
        let predicate = NSPredicate(format: "NOT id IN %@", shipIds)
        guard let ships = try? objects(with: Ship.entity, predicate: predicate)
            else { return [] }
        return ships
    }
    func shipsInFleet() -> [Ship] {
        let predicate = NSPredicate(format: "NOT fleet = 0")
        guard let ships = try? objects(with: Ship.entity, predicate: predicate)
            else { return [] }
        return ships
    }
    func createShip() -> Ship? {
        return insertNewObject(for: Ship.entity)
    }
    
    func masterSlotItemID(by slotItemId: Int) -> Int {
        if slotItemId < 1 { return 0 }
        let predicate = NSPredicate(format: "id = %d", argumentArray: [slotItemId])
        guard let slotItems = try? objects(with: SlotItem.entity, predicate: predicate),
            let slotItem = slotItems.first
            else { return 0 }
        return slotItem.master_slotItem.id
    }
    
    func slotItem(by itemId: Int) -> SlotItem? {
        let p = NSPredicate(format: "id = %ld", itemId)
        guard let slotItems = try? objects(with: SlotItem.entity, predicate: p)
            else { return nil }
        return slotItems.first
    }
    func sortedSlotItemsById() -> [SlotItem] {
        let sortDesc = NSSortDescriptor(key: "id", ascending: true)
        guard let slotItems = try? objects(with: SlotItem.entity, sortDescriptors: [sortDesc])
            else { return [] }
        return slotItems
    }
    func slotItems() -> [SlotItem] {
        guard let slotItems = try? objects(with: SlotItem.entity)
            else { return [] }
        return slotItems
    }
    func slotItems(in itemIds: [Int]) -> [SlotItem] {
        let predicate = NSPredicate(format: "id IN %@", itemIds)
        guard let slotItems = try? objects(with: SlotItem.entity, predicate: predicate)
            else { return [] }
        return slotItems
    }
    func slotItems(exclude itemIds: [Int]) -> [SlotItem] {
        let predicate = NSPredicate(format: "NOT id IN %@", itemIds)
        guard let slotItems = try? objects(with: SlotItem.entity, predicate: predicate)
            else { return [] }
        return slotItems
    }
    func createSlotItem() -> SlotItem? {
        return insertNewObject(for: SlotItem.entity)
    }
    
    func quests() -> [Quest] {
        guard let quests = try? objects(with: Quest.entity)
            else { return [] }
        return quests
    }
    func quest(by no: Int) -> Quest? {
        let p = NSPredicate(format: "%K = %ld", "no", no)
        guard let quests = try? objects(with: Quest.entity, predicate: p)
            else { return nil }
        return quests.first
    }
    func quests(in range: CountableClosedRange<Int>) -> [Quest] {
        let p = NSPredicate(format: "%K In %@", "no", range.map {$0})
        guard let quests = try? objects(with: Quest.entity, predicate: p)
            else { return [] }
        return quests
    }
    func sortedQuestByNo() -> [Quest] {
        let sortDesc = NSSortDescriptor(key: "no", ascending: true)
        guard let quests = try? objects(with: Quest.entity, sortDescriptors: [sortDesc])
            else { return [] }
        return quests
    }
    func createQuest() -> Quest? {
        return insertNewObject(for: Quest.entity)
    }
}
