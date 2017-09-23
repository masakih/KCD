//
//  LocalDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension CoreDataConfiguration {
    
    static let local = CoreDataConfiguration("LocalData")
}

final class LocalDataStore: CoreDataAccessor, CoreDataManager {
    
    static let core = CoreDataCore(.local)
    
    static let `default` = LocalDataStore(type: .reader)
    
    class func oneTimeEditor() -> LocalDataStore {
        
        return LocalDataStore(type: .editor)
    }
    
    required init(type: CoreDataManagerType) {
        
        context = LocalDataStore.context(for: type)
    }
    
    deinit {
        
        save()
    }
    
    let context: NSManagedObjectContext
}

extension LocalDataStore {
    
    func unmarkedDropShipHistories(befor days: Int) -> [DropShipHistory] {
        
        let date = Date(timeIntervalSinceNow: TimeInterval(-1 * days * 24 * 60 * 60))
        let predicate01 = NSPredicate(format: "date < %@", date as NSDate)
        let predicate02 = NSPredicate(format: "mark = 0 || mark = nil")
        let predicate03 = NSPredicate(format: "mapArea IN %@", ["1", "2", "3", "4", "5", "6", "7", "8", "9"])
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate01, predicate02, predicate03])
        
        guard let dropHistories = try? objects(of: DropShipHistory.entity, predicate: predicate)
            else { return [] }
        
        return dropHistories
    }
    
    func createDropShipHistory() -> DropShipHistory? {
        
        return insertNewObject(for: DropShipHistory.entity)
    }
    
    func kaihatuHistories() -> [KaihatuHistory] {
        
        guard let kaihatuHistories = try? objects(of: KaihatuHistory.entity)
            else { return [] }
        
        return kaihatuHistories
    }
    
    func unmarkedKaihatuHistories(befor days: Int) -> [KaihatuHistory] {
        
        let date = Date(timeIntervalSinceNow: TimeInterval(-1 * days * 24 * 60 * 60))
        let predicate01 = NSPredicate(format: "date < %@", date as NSDate)
        let predicate02 = NSPredicate(format: "mark = 0 || mark = nil")
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate01, predicate02])
        
        guard let kaihatuHistories = try? objects(of: KaihatuHistory.entity, predicate: predicate)
            else { return [] }
        
        return kaihatuHistories
    }
    
    func createKaihatuHistory() -> KaihatuHistory? {
        
        return insertNewObject(for: KaihatuHistory.entity)
    }
    
    func kenzoMark(byDockId dockId: Int) -> KenzoMark? {
        
        let predicate = NSPredicate(format: "kDockId = %ld", dockId)
        
        guard let kenzoMarks = try? objects(of: KenzoMark.entity, predicate: predicate)
            else { return nil }
        
        return kenzoMarks.first
    }
    
    // swiftlint:disable function_parameter_count
    func kenzoMark(fuel: Int, bull: Int, steel: Int, bauxite: Int, kaihatusizai: Int, kDockId: Int, shipId: Int) -> KenzoMark? {
        
        // swiftlint:disable:next line_length
        let predicate = NSPredicate(format: "fuel = %ld AND bull = %ld AND steel = %ld AND bauxite = %ld AND kaihatusizai = %ld AND kDockId = %ld AND created_ship_id = %ld",
                                    fuel, bull, steel, bauxite, kaihatusizai, kDockId, shipId)
        
        guard let kenzoMarks = try? objects(of: KenzoMark.entity, predicate: predicate)
            else { return nil }
        
        return kenzoMarks.first
    }
    
    func createKenzoMark() -> KenzoMark? {
        
        return insertNewObject(for: KenzoMark.entity)
    }
    
    func unmarkedKenzoHistories(befor days: Int) -> [KenzoHistory] {
        
        let date = Date(timeIntervalSinceNow: TimeInterval(-1 * days * 24 * 60 * 60))
        let predicate01 = NSPredicate(format: "date < %@", date as NSDate)
        let predicate02 = NSPredicate(format: "mark = 0 || mark = nil")
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate01, predicate02])
        
        guard let kenzoHistories = try? objects(of: KenzoHistory.entity, predicate: predicate)
            else { return [] }
        
        return kenzoHistories
    }
    
    func createKenzoHistory() -> KenzoHistory? {
        
        return insertNewObject(for: KenzoHistory.entity)
    }
    
    func hiddenDropShipHistories() -> [HiddenDropShipHistory] {
        
        guard let dropShipHistories = try? objects(of: HiddenDropShipHistory.entity)
            else { return [] }
        
        return dropShipHistories
    }
    
    func createHiddenDropShipHistory() -> HiddenDropShipHistory? {
        
        return insertNewObject(for: HiddenDropShipHistory.entity)
    }
}
