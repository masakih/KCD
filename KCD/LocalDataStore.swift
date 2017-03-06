//
//  LocalDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension CoreDataIntormation {
    static let local = CoreDataIntormation(
        modelName: "LocalData",
        storeFileName: "LocalData.storedata",
        storeOptions:[NSMigratePersistentStoresAutomaticallyOption: true,
                      NSInferMappingModelAutomaticallyOption: true],
        storeType: NSSQLiteStoreType,
        deleteAndRetry: false
    )
}
extension CoreDataCore {
    static let local = CoreDataCore(.local)
}

class LocalDataStore: CoreDataAccessor, CoreDataManager {
    static var `default` = LocalDataStore(type: .reader)
    class func oneTimeEditor() -> LocalDataStore {
        return LocalDataStore(type: .editor)
    }
    
    required init(type: CoreDataManagerType) {
        managedObjectContext =
            type == .reader ? core.parentManagedObjectContext
            : core.editorManagedObjectContext()
    }
    deinit {
        saveActionCore()
    }
    
    let core = CoreDataCore.local
    var managedObjectContext: NSManagedObjectContext
}

extension LocalDataStore {
    func unmarkedDropShipHistories(befor days: Int) -> [DropShipHistory] {
        let date = Date(timeIntervalSinceNow: TimeInterval(-1 * days * 24 * 60 * 60))
        let predicate01 = NSPredicate(format: "date < %@", date as NSDate)
        let predicate02 = NSPredicate(format: "mark = 0 || mark = nil")
        let predicate03 = NSPredicate(format: "mapArea IN %@", ["1", "2", "3", "4", "5", "6", "7", "8", "9"])
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate01, predicate02, predicate03])
        guard let k = try? objects(withEntityName: "DropShipHistory", predicate: predicate),
            let dropHistories = k as? [DropShipHistory]
            else { return [] }
        return dropHistories
    }
    
    func createDropShipHistory() -> DropShipHistory? {
        return insertNewObject(forEntityName: "DropShipHistory") as? DropShipHistory
    }
    
    func kaihatuHistories() -> [KaihatuHistory] {
        guard let k = try? objects(withEntityName: "KaihatuHistory"),
            let kaihatuHistories = k as? [KaihatuHistory]
            else { return [] }
        return kaihatuHistories
    }
    func unmarkedKaihatuHistories(befor days: Int) -> [KaihatuHistory] {
        let date = Date(timeIntervalSinceNow: TimeInterval(-1 * days * 24 * 60 * 60))
        let predicate01 = NSPredicate(format: "date < %@", date as NSDate)
        let predicate02 = NSPredicate(format: "mark = 0 || mark = nil")
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate01, predicate02])
        guard let k = try? objects(withEntityName: "KaihatuHistory", predicate: predicate),
            let kaihatuHistories = k as? [KaihatuHistory]
            else { return [] }
        return kaihatuHistories
    }
    func createKaihatuHistory() -> KaihatuHistory? {
        return insertNewObject(forEntityName: "KaihatuHistory") as? KaihatuHistory
    }
    
    func kenzoMark(byDockId dockId: Int) -> KenzoMark? {
        let predicate = NSPredicate(format: "kDockId = %ld", dockId)
        guard let km = try? objects(withEntityName: "KenzoMark", predicate: predicate),
            let kenzoMarks = km as? [KenzoMark],
            let kenzoMark = kenzoMarks.first
            else { return nil }
        return kenzoMark
    }
    func kenzoMark(fuel: Int, bull: Int, steel: Int, bauxite: Int, kaihatusizai: Int, kDockId: Int, shipId: Int) -> KenzoMark? {
        let predicate = NSPredicate(format: "fuel = %ld AND bull = %ld AND steel = %ld AND bauxite = %ld AND kaihatusizai = %ld AND kDockId = %ld AND created_ship_id = %ld"
            , fuel, bull, steel, bauxite, kaihatusizai, kDockId, shipId)
        guard let km = try? objects(withEntityName: "KenzoMark", predicate: predicate),
            let kenzoMarks = km as? [KenzoMark],
            let kenzoMark = kenzoMarks.first
            else { return nil }
        return kenzoMark
    }
    func createKenzoMark() -> KenzoMark? {
        return insertNewObject(forEntityName: "KenzoMark") as? KenzoMark
    }
    
    func unmarkedKenzoHistories(befor days: Int) -> [KenzoHistory] {
        let date = Date(timeIntervalSinceNow: TimeInterval(-1 * days * 24 * 60 * 60))
        let predicate01 = NSPredicate(format: "date < %@", date as NSDate)
        let predicate02 = NSPredicate(format: "mark = 0 || mark = nil")
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate01, predicate02])
        guard let k = try? objects(withEntityName: "KenzoHistory", predicate: predicate),
            let kenzoHistories = k as? [KenzoHistory]
            else { return [] }
        return kenzoHistories
    }
    func createKenzoHistory() -> KenzoHistory? {
        return insertNewObject(forEntityName: "KenzoHistory") as? KenzoHistory
    }
    
    func hiddenDropShipHistories() -> [DropShipHistory] {
        guard let d = try? objects(withEntityName: "HiddenDropShipHistory"),
            let dropShipHistories = d as? [DropShipHistory]
            else { return [] }
        return dropShipHistories
    }
    func createHiddenDropShipHistory() -> DropShipHistory? {
        return insertNewObject(forEntityName: "HiddenDropShipHistory") as? DropShipHistory
    }
}
