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

extension KCBattle: EntityProvider {
    override class var entityName: String { return "Battle" }
}
extension KCDamage: EntityProvider {
    override class var entityName: String { return "Damage" }
}
extension KCGuardEscaped: EntityProvider {
    override class var entityName: String { return "GuardEscaped" }
}

extension TemporaryDataStore {
    func battle() -> KCBattle? {
        return battles().first
    }
    func battles() -> [KCBattle] {
        guard let battles = try? self.objects(with: KCBattle.entity)
            else { return [] }
        return battles
    }
    func resetBattle() {
        battles().forEach { delete($0) }
    }
    func createBattle() -> KCBattle? {
        return insertNewObject(for: KCBattle.entity)
    }
    
    func sortedDamagesById() -> [KCDamage] {
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        guard let damages = try? objects(with: KCDamage.entity, sortDescriptors: [sortDescriptor])
            else { return [] }
        return damages
    }
    func damages() -> [KCDamage] {
        guard let damages = try? objects(with: KCDamage.entity)
            else { return [] }
        return damages
    }
    func createDamage() -> KCDamage? {
        return insertNewObject(for: KCDamage.entity)
    }
    
    func guardEscaped() -> [KCGuardEscaped] {
        guard let escapeds = try? objects(with: KCGuardEscaped.entity)
            else { return [] }
        return escapeds
    }
    func ensuredGuardEscaped(byShipId shipId: Int) -> KCGuardEscaped? {
        let p = NSPredicate(format: "shipID = %ld AND ensured = TRUE", shipId)
        guard let escapes = try? objects(with: KCGuardEscaped.entity, predicate: p)
            else { return nil }
        return escapes.first
    }
    func notEnsuredGuardEscaped() -> [KCGuardEscaped] {
        let predicate = NSPredicate(format: "ensured = FALSE")
        guard let escapeds = try? objects(with: KCGuardEscaped.entity, predicate: predicate)
            else { return [] }
        return escapeds
    }
    func createGuardEscaped() -> KCGuardEscaped? {
        return insertNewObject(for: KCGuardEscaped.entity)
    }
}
