//
//  TemporaryDataStoreAccessor.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/10/25.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Doutaku

extension TemporaryDataStore {
    
    func battle() -> Battle? {
        
        return battles().first
    }
    
    func battles() -> [Battle] {
        
        guard let battles = try? self.objects(of: Battle.entity) else { return [] }
        
        return battles
    }
    
    func resetBattle() {
        
        battles().forEach { delete($0) }
    }
    
    func createBattle() -> Battle? {
        
        return insertNewObject(for: Battle.entity)
    }
    
    func sortedDamagesById() -> [Damage] {
        
        let sortDescriptors = SortDescriptors(keyPath: \Damage.id, ascending: true)
        
        guard let damages = try? objects(of: Damage.entity, sortDescriptors: sortDescriptors) else { return [] }
        
        return damages
    }
    
    func damages() -> [Damage] {
        
        guard let damages = try? objects(of: Damage.entity) else { return [] }
        
        return damages
    }
    
    func createDamage() -> Damage? {
        
        return insertNewObject(for: Damage.entity)
    }
    
    func guardEscaped() -> [GuardEscaped] {
        
        guard let escapeds = try? objects(of: GuardEscaped.entity) else { return [] }
        
        return escapeds
    }
    
    func ensuredGuardEscaped(byShipId shipId: Int) -> GuardEscaped? {
        
        let predicate = Predicate(\GuardEscaped.shipID, equalTo: shipId)
            .and(Predicate(true: \GuardEscaped.ensured))
        
        guard let escapes = try? objects(of: GuardEscaped.entity, predicate: predicate) else { return nil }
        
        return escapes.first
    }
    
    func notEnsuredGuardEscaped() -> [GuardEscaped] {
        
        let predicate = Predicate(false: \GuardEscaped.ensured)
        
        guard let escapeds = try? objects(of: GuardEscaped.entity, predicate: predicate) else { return [] }
        
        return escapeds
    }
    
    func createGuardEscaped() -> GuardEscaped? {
        
        return insertNewObject(for: GuardEscaped.entity)
    }
}
