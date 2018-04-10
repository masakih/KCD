//
//  ResourceHistoryManager.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class ResourceHistoryManager: NSObject {
    
    private let periodicNotification = PeriodicNotifier(hour: 23, minutes: 3)
    
    override init() {
        
        super.init()
        
        notifyIfNeeded(nil)
        NotificationCenter.default
            .addObserver(forName: .Periodic,
                         object: periodicNotification,
                         queue: nil,
                         using: reduce)
    }
    
    private var timer: Timer?
    
    @objc private func notifyIfNeeded(_ timer: Timer?) {
        
        if timer != nil {
            
            saveResources()
        }
        
        timer?.invalidate()
        
        let now = Date()
        var nowComp = Calendar.current
            .dateComponents([.year, .month, .day, .hour, .minute], from: now)
        // 現在時刻を超える最小の５分刻みの分
        nowComp.minute = nowComp.minute
            .flatMap { $0 + 5 }
            .flatMap { ($0 + 2) / 5 }
            .flatMap { $0 * 5 }
        
        guard let notifyDate = Calendar.current.date(from: nowComp) else {
            
            print("ResourceHistoryManager: Can not create notify date")
            
            return
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: notifyDate.timeIntervalSinceNow,
                                          target: self,
                                          selector: #selector(ResourceHistoryManager.notifyIfNeeded(_:)),
                                          userInfo: nil,
                                          repeats: false)
    }
    
    private func saveResources() {
        
        let store = ServerDataStore.default
        
        guard let material = store.material() else {
            
            Logger.shared.log("ResourceHistoryManager: Can not get Material")
            
            return
        }
        
        guard let experience = store.sync(execute: { store.basic()?.experience }) else {
            
            Logger.shared.log("ResourceHistoryManager: Can not get Basic")
            
            return
        }
        
        let historyStore = ResourceHistoryDataStore.oneTimeEditor()
        historyStore.sync {
            guard let newHistory = historyStore.createResource() else {
                
                Logger.shared.log("ResourceHistoryManager: Can not create ResourceHIstory")
                
                return
            }
            
            let now = Date()
            var nowComp = Calendar.current
                .dateComponents([.year, .month, .day, .hour, .minute], from: now)
            let minutes = nowComp.minute.map { ($0 + 2) / 5 } ?? 0
            nowComp.minute = minutes * 5
            
            newHistory.date = Calendar.current.date(from: nowComp)!
            newHistory.minute = (minutes != 60) ? minutes : 0
            newHistory.fuel = store.sync { material.fuel }
            newHistory.bull = store.sync { material.bull }
            newHistory.steel = store.sync { material.steel }
            newHistory.bauxite = store.sync { material.bauxite }
            newHistory.kaihatusizai = store.sync { material.kaihatusizai }
            newHistory.kousokukenzo = store.sync { material.kousokukenzo }
            newHistory.kousokushuhuku = store.sync { material.kousokushuhuku }
            newHistory.screw = store.sync { material.screw }
            newHistory.experience = experience
        }
    }
    
    private func reduceResourceByConditions(_ store: ResourceHistoryDataStore, _ target: [Int], _ ago: Date) {
        
        store.sync {
            
            store.resources(in: target, older: ago).forEach(store.delete)
        }
    }
    
    private func dateOfMonth(_ month: Int) -> Date {
        
        return Date(timeIntervalSinceNow: TimeInterval(month * 30 * 24 * 60 * 60))
    }
    
    private func reduce(_ notification: Notification) {
        
        let queue = DispatchQueue(label: "ResourceHistoryManager")
        queue.async {
            
            let store = ResourceHistoryDataStore.oneTimeEditor()
            
            // 1 month
            self.reduceResourceByConditions(store,
                                            [5, 10, 20, 25, 35, 40, 50, 55],
                                            self.dateOfMonth(-1))
            
            // 3 months
            self.reduceResourceByConditions(store,
                                            [5, 10, 15, 20, 25, 35, 40, 45, 50, 55],
                                            self.dateOfMonth(-3))
            
            // 6 manths
            self.reduceResourceByConditions(store,
                                            [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55],
                                            self.dateOfMonth(-6))
        }
    }
}
