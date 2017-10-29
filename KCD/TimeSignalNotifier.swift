//
//  TimeSignalNotifier.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/21.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class TimeSignalNotifier: NSObject {
    
    let udController: NSUserDefaultsController = NSUserDefaultsController.shared
    
    override init() {
        
        super.init()
        
        registerTimer()
        bind(NSBindingName(#keyPath(notifyTimeBeforeTimeSignal)),
             to: udController,
             withKeyPath: "values.notifyTimeBeforeTimeSignal")
    }
    
    deinit {
        
        unbind(NSBindingName(#keyPath(notifyTimeBeforeTimeSignal)))
    }
    
    @objc dynamic var notifyTimeBeforeTimeSignal: Int = 0 {
        
        didSet { registerTimer() }
    }
    var timer: Timer?
    
    @objc func fire(_ timer: Timer) {
        
        defer { registerTimer() }
        
        guard UserDefaults.standard[.notifyTimeSignal] else { return }
        
        let now = Date()
        let cal = Calendar.current
        let minutes = cal.component(.minute, from: now)
        
        if (59 - minutes) > notifyTimeBeforeTimeSignal { return }
        
        let notification = NSUserNotification()
        let hour = cal.component(.hour, from: now)
        let format = LocalizedStrings.timerSIgnalMessage.string
        notification.title = String(format: format, hour + 1)
        notification.informativeText = notification.title
        
        if UserDefaults.standard[.playNotifyTimeSignalSound] {
            
            notification.soundName = NSUserNotificationDefaultSoundName
        }
        
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    private func registerTimer() {
        
        timer?.invalidate()
        
        let now = Date()
        let cal = Calendar.current
        var comp = cal.dateComponents([.year, .month, .day, .hour], from: now)
        let minutes = cal.component(.minute, from: now)
        if minutes + notifyTimeBeforeTimeSignal >= 60 {
            
            comp.hour = comp.hour.map { $0 + 1 }
            
        }
        comp.minute = 60 - notifyTimeBeforeTimeSignal
        guard let notifyDate = cal.date(from: comp) else {
            
            return Logger.shared.log("Can not create notify date")
        }
        
        timer = Timer.scheduledTimer(timeInterval: notifyDate.timeIntervalSinceNow,
                                     target: self,
                                     selector: #selector(TimeSignalNotifier.fire(_:)),
                                     userInfo: nil,
                                     repeats: false)
    }
}
