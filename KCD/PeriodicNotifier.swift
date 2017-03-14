//
//  PeriodicNotifier.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/03.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let Periodic = Notification.Name("com.masakih.KCD.Notification.Periodic")
}

fileprivate extension Selector {
    static let notifyIfNeeded = #selector(PeriodicNotifier.notifyIfNeeded(_:))
}

class PeriodicNotifier: NSObject {
    private let hour: Int
    private let minutes: Int
    
    init(hour: Int, minutes: Int) {
        self.hour = hour
        self.minutes = minutes
        super.init()
        
        let nc = NotificationCenter.default
        nc.addObserver(forName: .NSSystemTimeZoneDidChange, object: nil, queue: nil, using: notify)
        nc.addObserver(forName: .NSSystemClockDidChange, object: nil, queue: nil, using: notify)
        nc.addObserver(forName: .NSWorkspaceDidWake, object: nil, queue: nil, using: notify)
        
        notifyIfNeeded(nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func notify(_ notification: Notification) {
        notifyIfNeeded(nil)
    }
    
    @objc fileprivate func notifyIfNeeded(_ timer: Timer?) {
        let now = Date(timeIntervalSinceNow: 0.0)
        let unit: Set<Calendar.Component> = [.era, .year, .month, .day]
        var currentDay = Calendar.current.dateComponents(unit, from: now)
        currentDay.hour = hour
        currentDay.minute = minutes
        if let notifyDate = Calendar.current.date(from: currentDay),
            now.compare(notifyDate) == .orderedDescending {
            currentDay.day? += 1
            NotificationCenter.default.post(name: .Periodic, object: self)
        }
        if let v = timer?.isValid, v {
            timer?.invalidate()
        }
        guard let nextNotifyDate = Calendar.current.date(from: currentDay)
            else { fatalError("Can not create time of notify") }
        let nextNotifyTime = nextNotifyDate.timeIntervalSinceNow + 0.1
        Timer.scheduledTimer(timeInterval: nextNotifyTime,
                             target: self,
                             selector: .notifyIfNeeded,
                             userInfo: nil,
                             repeats: false)
    }
}
