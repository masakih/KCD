//
//  HistoryItemCleaner.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/18.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

class HistoryItemCleaner {
    func cleanOldHistoryItems() {
        guard UserDefaults.standard.cleanOldHistoryItems else {
            return
        }
        let store = LocalDataStore.oneTimeEditor()
        store.unmarkedKaihatuHistories(befor: UserDefaults.standard.cleanSiceDays)
            .forEach { store.delete($0) }
        store.unmarkedKenzoHistories(befor: UserDefaults.standard.cleanSiceDays)
            .forEach { store.delete($0) }
        store.unmarkedDropShipHistories(befor: UserDefaults.standard.cleanSiceDays)
            .forEach { store.delete($0) }
    }
}
