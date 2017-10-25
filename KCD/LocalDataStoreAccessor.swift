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
    
    func createDropShipHistory() -> DropShipHistory? {
        
        return insertNewObject(for: DropShipHistory.entity)
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
    
    // swiftlint:disable function_parameter_count
    func kenzoMark(fuel: Int, bull: Int, steel: Int, bauxite: Int, kaihatusizai: Int, kDockId: Int, shipId: Int) -> KenzoMark? {
        
        let predicate = NSPredicate.empty
            .and(NSPredicate(#keyPath(KenzoMark.fuel), equal: fuel))
            .and(NSPredicate(#keyPath(KenzoMark.bull), equal: bull))
            .and(NSPredicate(#keyPath(KenzoMark.steel), equal: steel))
            .and(NSPredicate(#keyPath(KenzoMark.bauxite), equal: bauxite))
            .and(NSPredicate(#keyPath(KenzoMark.kaihatusizai), equal: kaihatusizai))
            .and(NSPredicate(#keyPath(KenzoMark.kDockId), equal: kDockId))
            .and(NSPredicate(#keyPath(KenzoMark.created_ship_id), equal: shipId))
        
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
