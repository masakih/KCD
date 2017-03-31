//
//  TemporaryDataStore.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/06.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension CoreDataConfiguration {
    static let temporary = CoreDataConfiguration("Temporary",
                                                 fileName: ":memory:",
                                                 options: [:],
                                                 type: NSInMemoryStoreType
    )
}

class TemporaryDataStore: CoreDataAccessor, CoreDataManager {
    static let core = CoreDataCore(.temporary)
    
    static let `default` = TemporaryDataStore(type: .reader)
    class func oneTimeEditor() -> TemporaryDataStore {
        return TemporaryDataStore(type: .editor)
    }
    
    required init(type: CoreDataManagerType) {
        context = TemporaryDataStore.context(for: type)
    }
    deinit {
        save()
    }
    
    let context: NSManagedObjectContext
}

extension TemporaryDataStore {
    func battle() -> Battle? {
        return battles().first
    }
    func battles() -> [Battle] {
        guard let battles = try? self.objects(with: Battle.entity)
            else { return [] }
        return battles
    }
    func resetBattle() {
        battles().forEach { delete($0) }
    }
    func createBattle() -> Battle? {
        return insertNewObject(for: Battle.entity)
    }
    
    func sortedDamagesById() -> [Damage] {
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        guard let damages = try? objects(with: Damage.entity, sortDescriptors: [sortDescriptor])
            else { return [] }
        return damages
    }
    func damages() -> [Damage] {
        guard let damages = try? objects(with: Damage.entity)
            else { return [] }
        return damages
    }
    func createDamage() -> Damage? {
        return insertNewObject(for: Damage.entity)
    }
    
    func guardEscaped() -> [GuardEscaped] {
        guard let escapeds = try? objects(with: GuardEscaped.entity)
            else { return [] }
        return escapeds
    }
    func ensuredGuardEscaped(byShipId shipId: Int) -> GuardEscaped? {
        let p = NSPredicate(format: "shipID = %ld AND ensured = TRUE", shipId)
        guard let escapes = try? objects(with: GuardEscaped.entity, predicate: p)
            else { return nil }
        return escapes.first
    }
    func notEnsuredGuardEscaped() -> [GuardEscaped] {
        let predicate = NSPredicate(format: "ensured = FALSE")
        guard let escapeds = try? objects(with: GuardEscaped.entity, predicate: predicate)
            else { return [] }
        return escapeds
    }
    func createGuardEscaped() -> GuardEscaped? {
        return insertNewObject(for: GuardEscaped.entity)
    }
}
