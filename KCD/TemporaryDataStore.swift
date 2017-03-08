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
extension Entity {
    static let battle = Entity(name: "Battle")
    static let damage = Entity(name: "Damage")
    static let guardEscaped = Entity(name: "GuardEscaped")
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
        guard let a = try? self.objects(with: .battle),
            let array = a as? [KCBattle]
            else { return [] }
        return array
    }
    func resetBattle() {
        battles().forEach { delete($0) }
    }
    func createBattle() -> KCBattle? {
        return insertNewObject(for: .battle) as? KCBattle
    }
    
    func sortedDamagesById() -> [KCDamage] {
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        guard let a = try? objects(with: .damage, sortDescriptors: [sortDescriptor]),
            let array = a as? [KCDamage]
            else { return [] }
        return array
    }
    func damages() -> [KCDamage] {
        guard let a = try? objects(with: .damage),
            let array = a as? [KCDamage]
            else { return [] }
        return array
    }
    func createDamage() -> KCDamage? {
        return insertNewObject(for: .damage) as? KCDamage
    }
    
    func guardEscaped() -> [KCGuardEscaped] {
        guard let e = try? objects(with: .guardEscaped),
            let escapeds = e as? [KCGuardEscaped]
            else { return [] }
        return escapeds
    }
    func ensuredGuardEscaped(byShipId shipId: Int) -> KCGuardEscaped? {
        let p = NSPredicate(format: "shipID = %ld AND ensured = TRUE", shipId)
        guard let e = try? objects(with: .guardEscaped, predicate: p),
            let escapes = e as? [KCGuardEscaped],
            let escape = escapes.first
            else { return nil }
        return escape
    }
    func notEnsuredGuardEscaped() -> [KCGuardEscaped] {
        let predicate = NSPredicate(format: "ensured = FALSE")
        guard let e = try? objects(with: .guardEscaped, predicate: predicate),
            let escapeds = e as? [KCGuardEscaped]
            else { return [] }
        return escapeds
    }
    func createGuardEscaped() -> KCGuardEscaped? {
        return insertNewObject(for: .guardEscaped) as? KCGuardEscaped
    }
}
