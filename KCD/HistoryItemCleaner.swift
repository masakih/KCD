//
//  HistoryItemCleaner.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/18.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class HistoryItemCleaner {
    
    func cleanOldHistoryItems() {
        
        guard UserDefaults.standard[.cleanOldHistoryItems] else { return }
        
        let store = LocalDataStore.oneTimeEditor()
        store.sync {
            
            let cleanSinceDays = UserDefaults.standard[.cleanSinceDays]
            
            store.unmarkedKaihatuHistories(befor: cleanSinceDays).forEach(store.delete)
            store.unmarkedKenzoHistories(befor: cleanSinceDays).forEach(store.delete)
            store.unmarkedDropShipHistories(befor: cleanSinceDays).forEach(store.delete)
        }
    }
}
