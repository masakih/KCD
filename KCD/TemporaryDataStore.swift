//
//  TemporaryDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension CoreDataIntormation {
    static let temporary = CoreDataIntormation(
        modelName: "Temporary",
        storeFileName: ":memory:",
        storeOptions:[:],
        storeType: NSInMemoryStoreType,
        deleteAndRetry: false
    )
}
extension CoreDataCore {
    static let temporary = CoreDataCore(.temporary)
}

class TemporaryDataStore: CoreDataAccessor, CoreDataManager {
    static var `default` = TemporaryDataStore(type: .reader)
    class func oneTimeEditor() -> TemporaryDataStore {
        return TemporaryDataStore(type: .editor)
    }
    
    required init(type: CoreDataManagerType) {
        managedObjectContext =
            type == .reader ? core.parentManagedObjectContext
            : core.editorManagedObjectContext()
    }
    deinit {
        saveActionCore()
    }
    
    let core = CoreDataCore.temporary
    var managedObjectContext: NSManagedObjectContext
}

extension TemporaryDataStore {
    func battle() -> KCBattle? {
        return battles().first
    }
    func battles() -> [KCBattle] {
        guard let a = try? self.objects(withEntityName: "Battle"),
            let array = a as? [KCBattle]
            else { return [] }
        return array
    }
    func resetBattle() {
        battles().forEach { delete($0) }
    }
    
    func sortedDamagesById() -> [KCDamage] {
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        guard let a = try? objects(withEntityName: "Damage", sortDescriptors: [sortDescriptor]),
            let array = a as? [KCDamage]
            else { return [] }
        return array
    }
    func damages() -> [KCDamage] {
        guard let a = try? objects(withEntityName: "Damage"),
            let array = a as? [KCDamage]
            else { return [] }
        return array
    }
    func createDamage() -> KCDamage? {
        return insertNewObject(forEntityName: "Damage") as? KCDamage
    }
    
    func guardEscaped() -> [KCGuardEscaped] {
        guard let e = try? objects(withEntityName: "GuardEscaped"),
            let escapeds = e as? [KCGuardEscaped]
            else { return [] }
        return escapeds
    }
    func ensuredGuardEscaped(byShipId shipId: Int) -> KCGuardEscaped? {
        let p = NSPredicate(format: "shipID = %ld AND ensured = TRUE", shipId)
        guard let e = try? objects(withEntityName: "GuardEscaped", predicate: p),
            let escapes = e as? [KCGuardEscaped],
            let escape = escapes.first
            else { return nil }
        return escape
    }
    func notEnsuredGuardEscaped() -> [KCGuardEscaped] {
        let predicate = NSPredicate(format: "ensured = FALSE")
        guard let e = try? objects(withEntityName: "GuardEscaped", predicate: predicate),
            let escapeds = e as? [KCGuardEscaped]
            else { return [] }
        return escapeds
    }
    func createGuardEscaped() -> KCGuardEscaped? {
        return insertNewObject(forEntityName: "GuardEscaped") as? KCGuardEscaped
    }
}
