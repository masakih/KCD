//
//  NyukyoDockStatus.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

protocol NyukyoDockStatusObserver: class {
    
    func didUpdate(state: NyukyoDockStatus)
}

protocol NyukyoDockObserverDelegate: class {
    
    func didChangeState(dock: NyukyoDock)
}

final class NyukyoDockObserver {
    
    private let dock: NyukyoDock
    private var observation: NSKeyValueObservation?
    
    weak var delegate: NyukyoDockObserverDelegate? {
        
        didSet {
            delegate?.didChangeState(dock: dock)
        }
    }
    
    init(dock: NyukyoDock) {
        
        self.dock = dock
        
        observation = dock.observe(\NyukyoDock.state) { _, _ in
            
            self.delegate?.didChangeState(dock: self.dock)
        }
    }
}

final class NyukyoDockStatus: NSObject {
    
    private enum DockState: Int {
        
        case empty = 0
        
        case hasShip = 1
        
        case unknown = 999999
    }
    
    static func valid(number: Int) -> Bool {
        
        return  1...4 ~= number
    }

    let number: Int
    private let observer: NyukyoDockObserver
    
    private(set) var name: String?
    private(set) var time: TimeInterval?
    
    private var state: DockState = .unknown
    
    private var rawState: Int = 0 {
        
        didSet {
            
            state = DockState(rawValue: rawState) ?? .unknown
        }
    }
    private var shipId: Int = 0
    private var completeTime: Int = 0
    
    private var didNotify = false
    
    weak var delegate: NyukyoDockStatusObserver?
    
    /// CAUTION: 初回起動時/マスタ更新時にはデータがないので失敗する
    init?(number: Int) {
        
        guard NyukyoDockStatus.valid(number: number) else {
            
            return nil
        }
        
        self.number = number
        
        guard let dock = ServerDataStore.default.nyukyoDock(by: number) else {
            
            return nil
        }
        
        self.observer = NyukyoDockObserver(dock: dock)
        
        super.init()
                
        observer.delegate = self
    }
    
    private func updateState() {
        
        switch state {
            
        case .empty:
            didNotify = false
            name = nil
            time = nil
            
        case .hasShip:
            name = ServerDataStore.default.ship(by: shipId)?.name ?? "Unknown"
            
        case .unknown:
            Logger.shared.log("unknown State")
            
        }
        
        delegate?.didUpdate(state: self)
    }
}

extension NyukyoDockStatus: DockInformationUpdater {
    
    func update() {
        
        defer {
            
            delegate?.didUpdate(state: self)
        }
        
        guard let name = name else {
            
            return
        }
        
        let compTime = TimeInterval(Int(completeTime / 1_000))
        let diff = compTime - Date().timeIntervalSince1970
        
        // set to 0. if diff is less than 0.
        time = max(0, diff)
        
        // notify UserNotification.
        if didNotify {
            
            return
        }
        if diff >= 1 * 60 {
            
            return
        }
        
        let notification = NSUserNotification()
        let format = LocalizedStrings.dockingWillFinish.string
        notification.title = String(format: format, name)
        notification.informativeText = notification.title
        
        if UserDefaults.standard[.playFinishNyukyoSound] {
            
            notification.soundName = NSUserNotificationDefaultSoundName
        }
        
        NSUserNotificationCenter.default.deliver(notification)
        
        didNotify = true
    }
}

extension NyukyoDockStatus: NyukyoDockObserverDelegate {
    
    func didChangeState(dock: NyukyoDock) {
        
        rawState = dock.state
        shipId = dock.ship_id
        completeTime = dock.complete_time
        
        updateState()
    }
}
