//
//  LocalDataStoreAccessor.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/10/25.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

extension LocalDataStore {
    
    func unmarkedDropShipHistories(befor days: Int) -> [DropShipHistory] {
        
        let date = Date(timeIntervalSinceNow: TimeInterval(-1 * days * 24 * 60 * 60))
        let predicate = NSPredicate
            .and([
                NSPredicate(#keyPath(DropShipHistory.date), lessThan: date),
                NSPredicate(#keyPath(DropShipHistory.mark), equal: 0)
                    .or(.isNil(#keyPath(DropShipHistory.mark))),
                NSPredicate(#keyPath(DropShipHistory.mapArea), valuesIn: ["1", "2", "3", "4", "5", "6", "7", "8", "9"])
                ])
        
        guard let dropHistories = try? objects(of: DropShipHistory.entity, predicate: predicate) else { return [] }
        
        return dropHistories
    }
    
    func createDropShipHistory(from: HiddenDropShipHistory) -> DropShipHistory? {
        
        guard let new = insertNewObject(for: DropShipHistory.entity) else {
            
            Logger.shared.log("Can not create DropShipHistory")
            return nil
        }
        
        new.shipName = from.shipName
        new.mapArea = from.mapArea
        new.mapAreaName = from.mapAreaName
        new.mapInfo = from.mapInfo
        new.mapInfoName = from.mapInfoName
        new.mapCell = from.mapCell
        new.winRank = from.winRank
        new.date = from.date
        
        return new
    }
    
    func kaihatuHistories() -> [KaihatuHistory] {
        
        guard let kaihatuHistories = try? objects(of: KaihatuHistory.entity) else { return [] }
        
        return kaihatuHistories
    }
    
    func unmarkedKaihatuHistories(befor days: Int) -> [KaihatuHistory] {
        
        let date = Date(timeIntervalSinceNow: TimeInterval(-1 * days * 24 * 60 * 60))
        let predicate = NSPredicate
            .and([
                NSPredicate(#keyPath(KaihatuHistory.date), lessThan: date),
                NSPredicate(#keyPath(KaihatuHistory.mark), equal: 0)
                    .or(.isNil(#keyPath(KaihatuHistory.mark)))
                ])
        
        guard let kaihatuHistories = try? objects(of: KaihatuHistory.entity, predicate: predicate) else { return [] }
        
        return kaihatuHistories
    }
    
    func createKaihatuHistory() -> KaihatuHistory? {
        
        return insertNewObject(for: KaihatuHistory.entity)
    }
    
    func kenzoMark(byDockId dockId: Int) -> KenzoMark? {
        
        let predicate = NSPredicate(#keyPath(KenzoMark.kDockId), equal: dockId)
        
        guard let kenzoMarks = try? objects(of: KenzoMark.entity, predicate: predicate) else { return nil }
        
        return kenzoMarks.first
    }
    
    func kenzoMark(kenzoDock: KenzoDock, kDockId: Int) -> KenzoMark? {
        
        let predicate = NSPredicate.empty
            .and(NSPredicate(#keyPath(KenzoMark.fuel), equal: kenzoDock.item1))
            .and(NSPredicate(#keyPath(KenzoMark.bull), equal: kenzoDock.item2))
            .and(NSPredicate(#keyPath(KenzoMark.steel), equal: kenzoDock.item3))
            .and(NSPredicate(#keyPath(KenzoMark.bauxite), equal: kenzoDock.item4))
            .and(NSPredicate(#keyPath(KenzoMark.kaihatusizai), equal: kenzoDock.item5))
            .and(NSPredicate(#keyPath(KenzoMark.created_ship_id), equal: kenzoDock.created_ship_id))
            .and(NSPredicate(#keyPath(KenzoMark.kDockId), equal: kDockId))
        
        guard let kenzoMarks = try? objects(of: KenzoMark.entity, predicate: predicate) else { return nil }
        
        return kenzoMarks.first
    }
    
    func createKenzoMark() -> KenzoMark? {
        
        return insertNewObject(for: KenzoMark.entity)
    }
    
    func unmarkedKenzoHistories(befor days: Int) -> [KenzoHistory] {
        
        let date = Date(timeIntervalSinceNow: TimeInterval(-1 * days * 24 * 60 * 60))
        let predicate = NSPredicate
            .and([
                NSPredicate(#keyPath(KenzoHistory.date), lessThan: date),
                NSPredicate(#keyPath(KenzoHistory.mark), equal: 0)
                    .or(.isNil(#keyPath(KenzoHistory.mark)))
                ])
        
        guard let kenzoHistories = try? objects(of: KenzoHistory.entity, predicate: predicate) else { return [] }
        
        return kenzoHistories
    }
    
    func createKenzoHistory() -> KenzoHistory? {
        
        return insertNewObject(for: KenzoHistory.entity)
    }
    
    func hiddenDropShipHistories() -> [HiddenDropShipHistory] {
        
        guard let dropShipHistories = try? objects(of: HiddenDropShipHistory.entity) else { return [] }
        
        return dropShipHistories
    }
    
    func createHiddenDropShipHistory() -> HiddenDropShipHistory? {
        
        return insertNewObject(for: HiddenDropShipHistory.entity)
    }
}
