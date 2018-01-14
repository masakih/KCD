//
//  KenzoDockStatus.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

protocol KenzoDockStatusObserver: class {
    
    func didUpdate(state: KenzoDockStatus)
}

protocol KenzoDockStatusObserverDelegate: class {
    
    func didChangeState(dock: KenzoDock)
}

final class KenzoDockObserver {
    
    private let dock: KenzoDock
    private var observation: NSKeyValueObservation?
    
    weak var delegate: KenzoDockStatusObserverDelegate? {
        
        didSet {
            delegate?.didChangeState(dock: dock)
        }
    }
    
    init(dock: KenzoDock) {
        
        self.dock = dock
        
        observation = dock.observe(\KenzoDock.state) { _, _ in
            self.delegate?.didChangeState(dock: self.dock)
        }
    }
}

final class KenzoDockStatus: NSObject {
    
    private enum DockState: Int {
        
        case empty = 0
        case hasShip = 2
        case completed = 3
        case notOpen = -1
        
        case unknown = 999999
    }
    
    static func valid(number: Int) -> Bool {
        
        return 1...4 ~= number
    }
    
    let number: Int
    private let observer: KenzoDockObserver
    
    private(set) var time: TimeInterval?
    
    private var isTasking = false
    
    private var state: DockState = .unknown
    private var rawState: Int = 0 {
        
        didSet {
            state = DockState(rawValue: rawState) ?? .unknown
        }
    }
    private var completeTime: Int = 0
    
    private var didNotify = false
    
    weak var delegate: KenzoDockStatusObserver?
    
    /// CAUTION: 初回起動時/マスタ更新時にはデータがないので失敗する
    init?(number: Int) {
        
        guard KenzoDockStatus.valid(number: number) else { return nil }
        
        self.number = number
        
        guard let dock = ServerDataStore.default.kenzoDock(by: number) else { return nil }
        self.observer = KenzoDockObserver(dock: dock)
        
        super.init()
                
        observer.delegate = self
    }
    
    private func updateState() {
        
        switch state {
            
        case .empty, .notOpen:
            isTasking = false
            didNotify = false
            time = nil
            
        case .hasShip, .completed:
            isTasking = true
            
        case .unknown:
            Logger.shared.log("unknown State")
        }
        
        delegate?.didUpdate(state: self)
    }
}

extension KenzoDockStatus: DockInformationUpdater {
    
    func update() {
        
        defer {
            delegate?.didUpdate(state: self)
        }
        
        guard isTasking else { return }
        
        let compTime = TimeInterval(Int(completeTime / 1_000))
        let diff = compTime - Date().timeIntervalSince1970
        
        // set to 0. if diff is less than 0.
        time = max(0, diff)
        
        // notify UserNotification.
        if didNotify { return }
        if diff > 0 { return }
        
        let notification = NSUserNotification()
        let format = LocalizedStrings.buildingWillFinish.string
        notification.title = String(format: format, number as NSNumber)
        notification.informativeText = notification.title
        
        if UserDefaults.standard[.playFinishKenzoSound] {
            
            notification.soundName = NSUserNotificationDefaultSoundName
        }
        
        NSUserNotificationCenter.default.deliver(notification)
        
        didNotify = true
    }
    
}

extension KenzoDockStatus: KenzoDockStatusObserverDelegate {
    
    func didChangeState(dock: KenzoDock) {
        
        rawState = dock.state
        completeTime = dock.complete_time
        
        updateState()
    }
}
