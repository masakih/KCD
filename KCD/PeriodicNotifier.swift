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

final class PeriodicNotifier: NSObject {
    
    private let hour: Int
    private let minutes: Int
    
    init(hour: Int, minutes: Int) {
        
        self.hour = hour
        self.minutes = minutes
        
        super.init()
        
        let nc = NotificationCenter.default
        nc.addObserver(forName: .NSSystemTimeZoneDidChange, object: nil, queue: nil, using: notify)
        nc.addObserver(forName: .NSSystemClockDidChange, object: nil, queue: nil, using: notify)
        NSWorkspace.shared.notificationCenter
            .addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: nil, using: notify)
    }
    
    private func notify(_ notification: Notification) {
        
        notifyIfNeeded(nil)
    }
    
    @objc private func notifyIfNeeded(_ timer: Timer?) {
        
        let now = Date(timeIntervalSinceNow: 0.0)
        var currentDay = Calendar.current.dateComponents([.era, .year, .month, .day], from: now)
        currentDay.hour = hour
        currentDay.minute = minutes
        
        if let notifyDate = Calendar.current.date(from: currentDay),
            now.compare(notifyDate) == .orderedDescending {
            
            currentDay.day? += 1
            NotificationCenter.default.post(name: .Periodic, object: self)
        }
        
        timer?.invalidate()
        
        guard let nextNotifyDate = Calendar.current.date(from: currentDay) else {
            
            Logger.shared.log("Can not create time of notify")
            
            return
        }
        
        Timer.scheduledTimer(timeInterval: nextNotifyDate.timeIntervalSinceNow + 0.1,
                             target: self,
                             selector: #selector(PeriodicNotifier.notifyIfNeeded(_:)),
                             userInfo: nil,
                             repeats: false)
    }
}
