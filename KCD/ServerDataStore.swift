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

final class ServerDataStore: CoreDataManager {
    
    static let core = CoreDataCore(.kcd)
    
    static let `default` = ServerDataStore(type: .reader)
    
    class func oneTimeEditor() -> ServerDataStore {
        
        return ServerDataStore(type: .editor)
    }
    
    required init(type: CoreDataManagerType) {
        
        context = ServerDataStore.context(for: type)
    }
    
    deinit {
        
        save()
    }
    
    let context: NSManagedObjectContext
}

extension ServerDataStore {
    
    func airBases() -> [AirBase] {
        
        guard let airbase = try? objects(of: AirBase.entity) else { return [] }
        
        return airbase
    }
    
    func airBase(area: Int, base: Int) -> AirBase? {
        
        let p = NSPredicate.empty
            .and(NSPredicate(#keyPath(AirBase.area_id), equal: area))
            .and(NSPredicate(#keyPath(AirBase.rid), equal: base))
        
        guard let airBases = try? objects(of: AirBase.entity, predicate: p) else { return nil }
        
        return airBases.first
    }
    
    func createAirBasePlaneInfo() -> AirBasePlaneInfo? {
        
        return insertNewObject(for: AirBasePlaneInfo.entity)
    }
    
    func basic() -> Basic? {
        
        guard let basics = try? objects(of: Basic.entity) else { return nil }
        
        return basics.first
    }
    
    func createBasic() -> Basic? {
        
        return insertNewObject(for: Basic.entity)
    }
    
    func decksSortedById() -> [Deck] {
        
        let sortDec = NSSortDescriptor(key: #keyPath(Deck.id), ascending: true)
        
        guard let decks = try? objects(of: Deck.entity, sortDescriptors: [sortDec]) else { return [] }
        
        return decks
    }
    
    func deck(by id: Int) -> Deck? {
        
        let p = NSPredicate(#keyPath(Deck.id), equal: id)
        
        guard let decks = try? objects(of: Deck.entity, predicate: p) else { return nil }
        
        return decks.first
    }
    
    func kenzoDock(by dockId: Int) -> KenzoDock? {
        
        let dockPredicate = NSPredicate(#keyPath(KenzoDock.id), equal: dockId)
        
        guard let kenzoDocks = try? objects(of: KenzoDock.entity, predicate: dockPredicate) else { return nil }
        
        return kenzoDocks.first
    }
    
    func mapArea(by id: Int) -> MasterMapArea? {
        
        let predicate = NSPredicate(#keyPath(MasterMapArea.id), equal: id)
        guard let mapAreas = try? objects(of: MasterMapArea.entity, predicate: predicate) else { return nil }
        
        return mapAreas.first
    }
    
    func mapInfo(area: Int, no: Int) -> MasterMapInfo? {
        
        let predicate = NSPredicate.empty
            .and(NSPredicate(#keyPath(MasterMapInfo.maparea_id), equal: area))
            .and(NSPredicate(#keyPath(MasterMapInfo.no), equal: no))
        
        guard let mapInfos = try? objects(of: MasterMapInfo.entity, predicate: predicate) else { return nil }
        
        return mapInfos.first
    }
    
    func masterMission(by id: Int) -> MasterMission? {
        
        let p = NSPredicate(#keyPath(MasterMission.id), equal: id)
        
        guard let missions = try? objects(of: MasterMission.entity, predicate: p) else { return nil }
        
        return missions.first
    }
    
    func masterShips() -> [MasterShip] {
        
        guard let ships = try? objects(of: MasterShip.entity) else { return [] }
        
        return ships
    }
    
    func sortedMasterShipsById() -> [MasterShip] {
        
        let sortDesc = NSSortDescriptor(key: #keyPath(MasterShip.id), ascending: true)
        
        guard let ships = try? objects(of: MasterShip.entity, sortDescriptors: [sortDesc]) else { return [] }
        
        return ships
    }
    
    func masterShip(by id: Int) -> MasterShip? {
        
        let p = NSPredicate(#keyPath(MasterShip.id), equal: id)
        
        guard let ships = try? objects(of: MasterShip.entity, predicate: p) else { return nil }
        
        return ships.first
    }
    
    func sortedMasterSlotItemsById() -> [MasterSlotItem] {
        
        let sortDesc = NSSortDescriptor(key: #keyPath(MasterSlotItem.id), ascending: true)
        
        guard let masterSlotItems = try? objects(of: MasterSlotItem.entity, sortDescriptors: [sortDesc]) else { return [] }
        
        return masterSlotItems
    }
    
    func masterSlotItems() -> [MasterSlotItem] {
        
        guard let masterSlotItems = try? objects(of: MasterSlotItem.entity) else { return [] }
        
        return masterSlotItems
    }
    
    func masterSlotItem(by id: Int) -> MasterSlotItem? {
        
        let p = NSPredicate(#keyPath(MasterSlotItem.id), equal: id)
        
        guard let masterSlotItems = try? objects(of: MasterSlotItem.entity, predicate: p) else { return nil }
        
        return masterSlotItems.first
    }
    
    func masterSlotItemEquipType(by id: Int) -> MasterSlotItemEquipType? {
        
        let predicate = NSPredicate(#keyPath(MasterSlotItemEquipType.id), equal: id)
        
        guard let types = try? objects(of: MasterSlotItemEquipType.entity, predicate: predicate) else { return nil }
        
        return types.first
    }
    
    func masterSTypes() -> [MasterSType] {
        
        guard let masterSTypes = try? objects(of: MasterSType.entity) else { return [] }
        
        return masterSTypes
    }
    
    func sortedMasterSTypesById() -> [MasterSType] {
        
        let sortDesc = NSSortDescriptor(key: #keyPath(MasterSType.id), ascending: true)
        
        guard let masterSTypes = try? objects(of: MasterSType.entity, sortDescriptors: [sortDesc]) else { return [] }
        
        return masterSTypes
    }
    
    func material() -> Material? {
        
        guard let materials = try? objects(of: Material.entity) else { return nil }
        
        return materials.first
    }
    
    func createMaterial() -> Material? {
        
        return insertNewObject(for: Material.entity)
    }
    
    func nyukyoDock(by id: Int) -> NyukyoDock? {
        
        let p = NSPredicate(#keyPath(NyukyoDock.id), equal: id)
        
        guard let ndocks = try? objects(of: NyukyoDock.entity, predicate: p) else { return nil }
        
        return ndocks.first
    }
    
    func ships(byDeckId deckId: Int) -> [Ship] {
        
        let predicate = NSPredicate(#keyPath(Ship.id), equal: deckId)
        
        guard let decks = try? objects(of: Deck.entity, predicate: predicate) else { return [] }
        guard let deck = decks.first else { return [] }
        
        return deck[0...5]
    }
    
    func ship(by shipId: Int) -> Ship? {
        
        if shipId < 1 { return nil }
        
        let predicate = NSPredicate(#keyPath(Ship.id), equal: shipId)
        
        guard let ships = try? objects(of: Ship.entity, predicate: predicate) else { return nil }
        
        return ships.first
    }
    
    func ships(by shipId: Int) -> [Ship] {
        
        let predicate = NSPredicate(#keyPath(Ship.id), equal: shipId)
        
        guard let ships = try? objects(of: Ship.entity, predicate: predicate) else { return [] }
        
        return ships
    }
    
    func ships(exclude shipIds: [Int]) -> [Ship] {
        
        let predicate = NSPredicate.not(NSPredicate(#keyPath(Ship.id), valuesIn: shipIds))
        
        guard let ships = try? objects(of: Ship.entity, predicate: predicate) else { return [] }
        
        return ships
    }
    
    func shipsInFleet() -> [Ship] {
        
        let predicate = NSPredicate(#keyPath(Ship.fleet), notEqual: 0)
        
        guard let ships = try? objects(of: Ship.entity, predicate: predicate) else { return [] }
        
        return ships
    }
    
    func createShip() -> Ship? {
        
        return insertNewObject(for: Ship.entity)
    }
    
    func masterSlotItemID(by slotItemId: Int) -> Int {
        
        if slotItemId < 1 { return 0 }
        
        let predicate = NSPredicate(#keyPath(SlotItem.id), equal: slotItemId)
        
        guard let slotItems = try? objects(of: SlotItem.entity, predicate: predicate) else { return 0 }
        guard let slotItem = slotItems.first else { return 0 }
        
        return slotItem.master_slotItem.id
    }
    
    func slotItem(by itemId: Int) -> SlotItem? {
        
        let p = NSPredicate(#keyPath(SlotItem.id), equal: itemId)
        
        guard let slotItems = try? objects(of: SlotItem.entity, predicate: p) else { return nil }
        
        return slotItems.first
    }
    
    func sortedSlotItemsById() -> [SlotItem] {
        
        let sortDesc = NSSortDescriptor(key: #keyPath(SlotItem.id), ascending: true)
        
        guard let slotItems = try? objects(of: SlotItem.entity, sortDescriptors: [sortDesc]) else { return [] }
        
        return slotItems
    }
    
    func slotItems() -> [SlotItem] {
        
        guard let slotItems = try? objects(of: SlotItem.entity) else { return [] }
        
        return slotItems
    }
    
    func slotItems(in itemIds: [Int]) -> [SlotItem] {
        
        let predicate = NSPredicate(#keyPath(SlotItem.id), valuesIn: itemIds)
        
        guard let slotItems = try? objects(of: SlotItem.entity, predicate: predicate) else { return [] }
        
        return slotItems
    }
    
    func slotItems(exclude itemIds: [Int]) -> [SlotItem] {
        
        let predicate = NSPredicate.not(NSPredicate(#keyPath(SlotItem.id), valuesIn: itemIds))
        
        guard let slotItems = try? objects(of: SlotItem.entity, predicate: predicate) else { return [] }
        
        return slotItems
    }
    
    func createSlotItem() -> SlotItem? {
        
        return insertNewObject(for: SlotItem.entity)
    }
    
    func quests() -> [Quest] {
        
        guard let quests = try? objects(of: Quest.entity) else { return [] }
        
        return quests
    }
    
    func quest(by no: Int) -> Quest? {
        
        let p = NSPredicate(#keyPath(Quest.no), equal: no)
        
        guard let quests = try? objects(of: Quest.entity, predicate: p) else { return nil }
        
        return quests.first
    }
    
    func quests(in range: CountableClosedRange<Int>) -> [Quest] {
        
        let p = NSPredicate(#keyPath(Quest.no), valuesIn: range.map {$0})
        
        guard let quests = try? objects(of: Quest.entity, predicate: p) else { return [] }
        
        return quests
    }
    
    func sortedQuestByNo() -> [Quest] {
        
        let sortDesc = NSSortDescriptor(key: #keyPath(Quest.no), ascending: true)
        
        guard let quests = try? objects(of: Quest.entity, sortDescriptors: [sortDesc]) else { return [] }
        
        return quests
    }
    
    func createQuest() -> Quest? {
        
        return insertNewObject(for: Quest.entity)
    }
}
