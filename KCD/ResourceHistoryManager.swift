//
//  ResourceHistoryManager.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate extension Selector {
    static let notifyIfNeeded = #selector(ResourceHistoryManager.notifyIfNeeded(_:))
}

class ResourceHistoryManager: NSObject {
    private let periodicNotification: PeriodicNotifier
    
    override init() {
        periodicNotification = PeriodicNotifier(hour: 23, minutes: 3)
        super.init()
        notifyIfNeeded(nil)
        NotificationCenter.default
        .addObserver(forName: .Periodic,
                     object: periodicNotification,
                     queue: nil,
                     using: reduce)
    }
    
    private var timer: Timer?
    
    @objc fileprivate func notifyIfNeeded(_ timer: Timer?) {
        if timer != nil { saveResources() }
        if let valid = timer?.isValid, valid { timer?.invalidate() }
        
        let now = Date()
        var nowComp = Calendar.current
            .dateComponents([.year, .month, .day, .hour, .minute], from: now)
        // 現在時刻を超える最小の５分刻みの分
        nowComp.minute = nowComp.minute
            .flatMap { $0 + 5 }
            .flatMap { ($0 + 2) / 5 }
            .flatMap { $0 * 5 }
        guard let notifyDate = Calendar.current.date(from: nowComp)
            else { return print("ResourceHistoryManager: Can not create notify date") }
        let notifyTime = notifyDate.timeIntervalSinceNow
        self.timer = Timer.scheduledTimer(timeInterval: notifyTime,
                                          target: self,
                                          selector: .notifyIfNeeded,
                                          userInfo: nil,
                                          repeats: false)
    }
    private func saveResources() {
        let store = ServerDataStore.default
        guard let material = store.material()
            else { return print("ResourceHistoryManager: Can not get Material") }
        guard let basic = store.basic()
            else { return print("ResourceHistoryManager: Can not get Basic") }
        
        let historyStore = ResourceHistoryDataStore.oneTimeEditor()
        guard let newHistory = historyStore.cerateResource()
            else { return print("ResourceHistoryManager: Can not create ResourceHIstory") }
        let now = Date()
        var nowComp = Calendar.current
            .dateComponents([.year, .month, .day, .hour, .minute], from: now)
        var minutes: Int = (nowComp.minute! + 2) / 5
        minutes *= 5
        nowComp.minute = minutes
        
        newHistory.date = Calendar.current.date(from: nowComp)!
        newHistory.minute = (minutes != 60) ? minutes : 0
        newHistory.fuel = material.fuel
        newHistory.bull = material.bull
        newHistory.steel = material.steel
        newHistory.bauxite = material.bauxite
        newHistory.kaihatusizai = material.kaihatusizai
        newHistory.kousokukenzo = material.kousokukenzo
        newHistory.kousokushuhuku = material.kousokushuhuku
        newHistory.screw = material.screw
        newHistory.experience = basic.experience 
    }
    private func reduceResourceByConditions(_ store: ResourceHistoryDataStore,
                                            _ target: [Int],
                                            _ ago: Date) {
        store.resources(in: target, older: ago).forEach { store.delete($0) }
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
