//
//  LocalDataStoreAccessor.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/10/25.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Doutaku

extension LocalDataStore {
    
    func unmarkedDropShipHistories(befor days: Int) -> [DropShipHistory] {
        
        let date = Date(timeIntervalSinceNow: TimeInterval(-1 * days * 24 * 60 * 60))
        let predicate = Predicate(\DropShipHistory.date, lessThan: date)
            .and(
                Predicate(false: \DropShipHistory.mark)
                    .or(Predicate(isNil: \DropShipHistory.mark))
            )
            .and(Predicate(\DropShipHistory.mapArea, in: ["1", "2", "3", "4", "5", "6", "7", "8", "9"]))
        
        guard let dropHistories = try? objects(of: DropShipHistory.entity, predicate: predicate) else {
            
            return []
        }
        
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
        
        guard let kaihatuHistories = try? objects(of: KaihatuHistory.entity) else {
            
            return []
        }
        
        return kaihatuHistories
    }
    
    func unmarkedKaihatuHistories(befor days: Int) -> [KaihatuHistory] {
        
        let date = Date(timeIntervalSinceNow: TimeInterval(-1 * days * 24 * 60 * 60))
        let predicate = Predicate(\KaihatuHistory.date, lessThan: date)
            .and(
                Predicate(false: \KaihatuHistory.mark)
                    .or(Predicate(isNil: \KaihatuHistory.mark))
        )
        
        guard let kaihatuHistories = try? objects(of: KaihatuHistory.entity, predicate: predicate) else {
            
            return []
        }
        
        return kaihatuHistories
    }
    
    func createKaihatuHistory() -> KaihatuHistory? {
        
        return insertNewObject(for: KaihatuHistory.entity)
    }
    
    func kenzoMark(byDockId dockId: Int) -> KenzoMark? {
        
        let predicate = Predicate(\KenzoMark.kDockId, equalTo: dockId)
        
        guard let kenzoMarks = try? objects(of: KenzoMark.entity, predicate: predicate) else {
            
            return nil
        }
        
        return kenzoMarks.first
    }
    
    func kenzoMark(docInfo: KenzoMarkCommand.KenzoDockInfo) -> KenzoMark? {
        
        let predicate = Predicate(\KenzoMark.kDockId, equalTo: docInfo.dockId)
            .and(Predicate(\KenzoMark.fuel, equalTo: docInfo.fuel))
            .and(Predicate(\KenzoMark.bull, equalTo: docInfo.bull))
            .and(Predicate(\KenzoMark.steel, equalTo: docInfo.bull))
            .and(Predicate(\KenzoMark.bauxite, equalTo: docInfo.bauxite))
            .and(Predicate(\KenzoMark.kaihatusizai, equalTo: docInfo.kaihatusizai))
            .and(Predicate(\KenzoMark.created_ship_id, equalTo: docInfo.shipId))
        
        guard let kenzoMarks = try? objects(of: KenzoMark.entity, predicate: predicate) else {
            
            return nil
        }
        
        return kenzoMarks.first
    }
    
    func createKenzoMark() -> KenzoMark? {
        
        return insertNewObject(for: KenzoMark.entity)
    }
    
    func unmarkedKenzoHistories(befor days: Int) -> [KenzoHistory] {
        
        let date = Date(timeIntervalSinceNow: TimeInterval(-1 * days * 24 * 60 * 60))
        let predicate = Predicate(\KenzoHistory.date, lessThan: date)
            .and(
                Predicate(\KenzoHistory.mark, equalTo: false)
                    .or(Predicate(isNil: \KenzoHistory.mark))
        )
        
        guard let kenzoHistories = try? objects(of: KenzoHistory.entity, predicate: predicate) else {
            
            return []
        }
        
        return kenzoHistories
    }
    
    func createKenzoHistory() -> KenzoHistory? {
        
        return insertNewObject(for: KenzoHistory.entity)
    }
    
    func hiddenDropShipHistories() -> [HiddenDropShipHistory] {
        
        guard let dropShipHistories = try? objects(of: HiddenDropShipHistory.entity) else {
            
            return []
        }
        
        return dropShipHistories
    }
    
    func createHiddenDropShipHistory() -> HiddenDropShipHistory? {
        
        return insertNewObject(for: HiddenDropShipHistory.entity)
    }
}
