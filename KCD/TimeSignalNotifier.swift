//
//  TimeSignalNotifier.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/21.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension Selector {
    static let fire = #selector(TimeSignalNotifier.fire(_:))
}

class TimeSignalNotifier: NSObject {
    let udController: NSUserDefaultsController = NSUserDefaultsController.shared()
    
    override init() {
        super.init()
        registerTimer()
        self.bind("notifyTimeBeforeTimeSignal",
                  to: udController,
                  withKeyPath: "values.notifyTimeBeforeTimeSignal")
    }
    deinit {
        self.unbind("notifyTimeBeforeTimeSignal")
    }
    
    dynamic var notifyTimeBeforeTimeSignal: Int = 0 {
        didSet { registerTimer() }
    }
    var timer: Timer?
    
    func fire(_ timer: Timer) {
        defer { registerTimer() }
                
        let now = Date()
        let cal = Calendar.current
        let minutes = cal.component(.minute, from: now)
        
        if (59 - minutes) > notifyTimeBeforeTimeSignal { return }
        
        let notification = NSUserNotification()
        let hour = cal.component(.hour, from: now)
        let format = NSLocalizedString("It is soon %zd o'clock.",
                                       comment: "It is soon %zd o'clock.")
        notification.title = String(format: format, hour + 1)
        notification.informativeText = notification.title
        if UserDefaults.standard.playNotifyTimeSignalSound {
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
        if (59 - minutes) <= notifyTimeBeforeTimeSignal {
            comp.hour = comp.hour! + 1
        }
        comp.minute = 60 - notifyTimeBeforeTimeSignal
        guard let notifyDate = cal.date(from: comp)
            else { return print("Can not create notify date") }
        timer = Timer.scheduledTimer(timeInterval: notifyDate.timeIntervalSinceNow,
                                     target: self,
                                     selector: .fire,
                                     userInfo: nil,
                                     repeats: false)
    }
}
