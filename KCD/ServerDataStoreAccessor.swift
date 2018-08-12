//
//  ServerDataStoreAccessor.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/10/25.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Doutaku

extension ServerDataStore {
    
    func airBases() -> [AirBase] {
        
        guard let airbase = try? objects(of: AirBase.self) else {
            
            return []
        }
        
        return airbase
    }
    
    func airBase(area: Int, base: Int) -> AirBase? {
        
        let predicate = Predicate(\AirBase.area_id, equalTo: area)
            .and(Predicate(\AirBase.rid, equalTo: base))
        
        guard let airBases = try? objects(of: AirBase.self, predicate: predicate) else {
            
            return nil
        }
        
        return airBases.first
    }
    
    func createAirBasePlaneInfo() -> AirBasePlaneInfo? {
        
        return insertNewObject(for: AirBasePlaneInfo.self)
    }
    
    func basic() -> Basic? {
        
        guard let basics = try? objects(of: Basic.self) else {
            
            return nil
        }
        
        return basics.first
    }
    
    func createBasic() -> Basic? {
        
        return insertNewObject(for: Basic.self)
    }
    
    func decksSortedById() -> [Deck] {
        
        let sortDecs = SortDescriptors(keyPath: \Deck.id, ascending: true)
        
        guard let decks = try? objects(of: Deck.self, sortDescriptors: sortDecs) else {
            
            return []
        }
        
        return decks
    }
    
    func deck(by id: Int) -> Deck? {
        
        let predicate = Predicate(\Deck.id, equalTo: id)
        
        guard let decks = try? objects(of: Deck.self, predicate: predicate) else {
            
            return nil
        }
        
        return decks.first
    }
    
    func kenzoDock(by dockId: Int) -> KenzoDock? {
        
        let predicate = Predicate(\KenzoDock.id, equalTo: dockId)
        
        guard let kenzoDocks = try? objects(of: KenzoDock.self, predicate: predicate) else {
            
            return nil
        }
        
        return kenzoDocks.first
    }
    
    func mapArea(by id: Int) -> MasterMapArea? {
        
        let predicate = Predicate(\MasterMapArea.id, equalTo: id)
        
        guard let mapAreas = try? objects(of: MasterMapArea.self, predicate: predicate) else {
            
            return nil
        }
        
        return mapAreas.first
    }
    
    func mapInfo(area: Int, no: Int) -> MasterMapInfo? {
        
        let predicate = Predicate(\MasterMapInfo.maparea_id, equalTo: area)
            .and(Predicate(\MasterMapInfo.no, equalTo: no))
        
        guard let mapInfos = try? objects(of: MasterMapInfo.self, predicate: predicate) else {
            
            return nil
        }
        
        return mapInfos.first
    }
    
    func masterMission(by id: Int) -> MasterMission? {
        
        let predicate = Predicate(\MasterMission.id, equalTo: id)
        
        guard let missions = try? objects(of: MasterMission.self, predicate: predicate) else {
            
            return nil
        }
        
        return missions.first
    }
    
    func masterShips() -> [MasterShip] {
        
        guard let ships = try? objects(of: MasterShip.self) else {
            
            return []
        }
        
        return ships
    }
    
    func sortedMasterShipsById() -> [MasterShip] {
        
        let sortDescs = SortDescriptors(keyPath: \MasterShip.id, ascending: true)
        
        guard let ships = try? objects(of: MasterShip.self, sortDescriptors: sortDescs) else {
            
            return []
        }
        
        return ships
    }
    
    func masterShip(by id: Int) -> MasterShip? {
        
        let predicate = Predicate(\MasterShip.id, equalTo: id)
        
        guard let ships = try? objects(of: MasterShip.self, predicate: predicate) else {
            
            return nil
        }
        
        return ships.first
    }
    
    func sortedMasterSlotItemsById() -> [MasterSlotItem] {
        
        let sortDescs = SortDescriptors(keyPath: \MasterSlotItem.id, ascending: true)
        
        guard let masterSlotItems = try? objects(of: MasterSlotItem.self, sortDescriptors: sortDescs) else {
            
            return []
        }
        
        return masterSlotItems
    }
    
    func masterSlotItems() -> [MasterSlotItem] {
        
        guard let masterSlotItems = try? objects(of: MasterSlotItem.self) else {
            
            return []
        }
        
        return masterSlotItems
    }
    
    func masterSlotItem(by id: Int) -> MasterSlotItem? {
        
        let predicate = Predicate(\MasterSlotItem.id, equalTo: id)
        
        guard let masterSlotItems = try? objects(of: MasterSlotItem.self, predicate: predicate) else {
            
            return nil
        }
        
        return masterSlotItems.first
    }
    
    func masterSlotItemEquipType(by id: Int) -> MasterSlotItemEquipType? {
        
        let predicate = Predicate(\MasterSlotItemEquipType.id, equalTo: id)
        
        guard let types = try? objects(of: MasterSlotItemEquipType.self, predicate: predicate) else {
            
            return nil
        }
        
        return types.first
    }
    
    func masterSTypes() -> [MasterSType] {
        
        guard let masterSTypes = try? objects(of: MasterSType.self) else {
            
            return []
        }
        
        return masterSTypes
    }
    
    func sortedMasterSTypesById() -> [MasterSType] {
        
        let sortDescs = SortDescriptors(keyPath: \MasterSType.id, ascending: true)
        
        guard let masterSTypes = try? objects(of: MasterSType.self, sortDescriptors: sortDescs) else {
            
            return []
        }
        
        return masterSTypes
    }
    
    func material() -> Material? {
        
        guard let materials = try? objects(of: Material.self) else {
            
            return nil
        }
        
        return materials.first
    }
    
    func createMaterial() -> Material? {
        
        return insertNewObject(for: Material.self)
    }
    
    func nyukyoDock(by id: Int) -> NyukyoDock? {
        
        let predicate = Predicate(\NyukyoDock.id, equalTo: id)
        
        guard let ndocks = try? objects(of: NyukyoDock.self, predicate: predicate) else {
            
            return nil
        }
        
        return ndocks.first
    }
    
    func ships(byDeckId deckId: Int) -> [Ship] {
        
        let predicate = Predicate(\Deck.id, equalTo: deckId)
        
        guard let decks = try? objects(of: Deck.self, predicate: predicate) else {
            
            return []
        }
        
        guard let deck = decks.first else {
            
            return []
        }
        
        return deck[0..<Deck.maxShipCount]
    }
    
    func ship(by shipId: Int) -> Ship? {
        
        if shipId < 1 {
            
            return nil
        }
        
        let predicate = Predicate(\Ship.id, equalTo: shipId)
        
        guard let ships = try? objects(of: Ship.self, predicate: predicate) else {
            
            return nil
        }
        
        return ships.first
    }
    
    func ships(by shipId: Int) -> [Ship] {
        
        let predicate = Predicate(\Ship.id, equalTo: shipId)
        
        guard let ships = try? objects(of: Ship.self, predicate: predicate) else {
            
            return []
        }
        
        return ships
    }
    
    func ships(exclude shipIds: [Int]) -> [Ship] {
        
        let predicate = Predicate(\Ship.id, in: shipIds).negate()
        
        guard let ships = try? objects(of: Ship.self, predicate: predicate) else {
            
            return []
        }
        
        return ships
    }
    
    func shipsInFleet() -> [Ship] {
        
        let predicate = Predicate(\Ship.fleet, notEqualTo: 0)
        
        guard let ships = try? objects(of: Ship.self, predicate: predicate) else {
            
            return []
        }
        
        return ships
    }
    
    func createShip() -> Ship? {
        
        return insertNewObject(for: Ship.self)
    }
    
    func masterSlotItemID(by slotItemId: Int) -> Int {
        
        if slotItemId < 1 {
            
            return 0
        }
        
        let predicate = Predicate(\SlotItem.id, equalTo: slotItemId)
        
        guard let slotItems = try? objects(of: SlotItem.self, predicate: predicate) else {
            
            return 0
        }
        guard let slotItem = slotItems.first else {
            
            return 0
        }
        
        return slotItem.master_slotItem.id
    }
    
    func slotItem(by itemId: Int) -> SlotItem? {
        
        let predicate = Predicate(\SlotItem.id, equalTo: itemId)
        
        guard let slotItems = try? objects(of: SlotItem.self, predicate: predicate) else {
            
            return nil
        }
        
        return slotItems.first
    }
    
    func sortedSlotItemsById() -> [SlotItem] {
        
        let sortDescs = SortDescriptors(keyPath: \SlotItem.id, ascending: true)
        
        guard let slotItems = try? objects(of: SlotItem.self, sortDescriptors: sortDescs) else {
            
            return []
        }
        
        return slotItems
    }
    
    func slotItems() -> [SlotItem] {
        
        guard let slotItems = try? objects(of: SlotItem.self) else {
            
            return []
        }
        
        return slotItems
    }
    
    func slotItems(in itemIds: [Int]) -> [SlotItem] {
        
        let predicate = Predicate(\SlotItem.id, in: itemIds)
        
        guard let slotItems = try? objects(of: SlotItem.self, predicate: predicate) else {
            
            return []
        }
        
        return slotItems
    }
    
    func slotItems(exclude itemIds: [Int]) -> [SlotItem] {
        
        let predicate = Predicate(\SlotItem.id, in: itemIds).negate()
        
        guard let slotItems = try? objects(of: SlotItem.self, predicate: predicate) else {
            
            return []
        }
        
        return slotItems
    }
    
    func createSlotItem() -> SlotItem? {
        
        return insertNewObject(for: SlotItem.self)
    }
    
    func quests() -> [Quest] {
        
        guard let quests = try? objects(of: Quest.self) else {
            
            return []
        }
        
        return quests
    }
    
    func quest(by no: Int) -> Quest? {
        
        let predicate = Predicate(\Quest.no, equalTo: no)
        
        guard let quests = try? objects(of: Quest.self, predicate: predicate) else {
            
            return nil
        }
        
        return quests.first
    }
    
    func quests(in range: CountableClosedRange<Int>) -> [Quest] {
        
        let predicate = Predicate(\Quest.no, in: range.map { $0 })
        
        guard let quests = try? objects(of: Quest.self, predicate: predicate) else {
            
            return []
        }
        
        return quests
    }
    
    func sortedQuestByNo() -> [Quest] {
        
        let sortDescs = SortDescriptors(keyPath: \Quest.no, ascending: true)
        
        guard let quests = try? objects(of: Quest.self, sortDescriptors: sortDescs) else {
            
            return []
        }
        
        return quests
    }
    
    func createQuest() -> Quest? {
        
        return insertNewObject(for: Quest.self)
    }
}
