
//
//  MissionStatus.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

protocol MissionStatusObserver: class {
    
    func didUpdate(state: MissionStatus)
}

protocol DeckMissionObserverDelegate: class {
    
    func didChangeState(deck: Deck)
}

final class DeckMissionObserver {
    
    private let deck: Deck
    private var observation: NSKeyValueObservation?
    
    weak var delegate: DeckMissionObserverDelegate? {
        
        didSet {
            
            delegate?.didChangeState(deck: deck)
        }
    }
    
    init(deck: Deck) {
        
        self.deck = deck
        
        observation = deck.observe(\Deck.mission_2) { _, _ in
            
            self.delegate?.didChangeState(deck: deck)
        }
    }
}

final class MissionStatus: NSObject {
    
    private enum State: Int {
        
        case none = 0
        
        case hasMission = 1
        
        case finish = 2
        
        case earlyReturn = 3
        
        case unknown = 999999
    }
    
    static func valid(number: Int) -> Bool {
        
        return 2...4 ~= number
    }
    
    let number: Int
    private let observer: DeckMissionObserver
    
    private(set) var name: String?
    private(set) var time: TimeInterval?
    
    private var state: State = .unknown
    private var rawState: Int = 0 {
        
        didSet {
            
            state = State(rawValue: rawState) ?? .unknown
        }
    }
    private var missionId: Int = 0
    private var milliseconds: Int = 0
    private var fleetName: String = ""
    
    private var didNotify = false
    
    weak var delegate: MissionStatusObserver?
    
    /// CAUTION: 初回起動時/マスタ更新時にはデータがないので失敗する
    init?(number: Int) {
        
        guard MissionStatus.valid(number: number) else {
            
            return nil
        }
        
        self.number = number
        
        guard let deck = ServerDataStore.default.deck(by: number) else {
            
            return nil
        }
        
        self.observer = DeckMissionObserver(deck: deck)
        
        super.init()
        
        observer.delegate = self
    }
    
    private func updateState() {
        
        switch state {
            
        case .none, .finish:
            didNotify = false
            name = nil
            time = nil
            
        case .hasMission, .earlyReturn:
            name = ServerDataStore.default.masterMission(by: missionId)?.name ?? "Unknown"
            
        case .unknown:
            Logger.shared.log("unknown State")
            
        }
        
        delegate?.didUpdate(state: self)
    }
}

extension MissionStatus: DockInformationUpdater {
    
    func update() {
        
        defer {
            
            delegate?.didUpdate(state: self)
        }
        
        guard let name = name else {
            
            return
        }
        
        let compTime = TimeInterval(Int(milliseconds / 1_000))
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
        let format = LocalizedStrings.missionWillReturnMessage.string
        notification.title = String(format: format, fleetName)
        let txtFormat = LocalizedStrings.missionWillReturnInformation.string
        notification.informativeText = String(format: txtFormat, fleetName, name)
        
        if UserDefaults.standard[.playFinishMissionSound] {
            
            notification.soundName = NSUserNotificationDefaultSoundName
        }
        
        NSUserNotificationCenter.default.deliver(notification)
        
        didNotify = true
    }
}

extension MissionStatus: DeckMissionObserverDelegate {
    
    func didChangeState(deck: Deck) {
        
        rawState = deck.mission_0
        missionId = deck.mission_1
        milliseconds = deck.mission_2
        fleetName = deck.name
        
        updateState()
    }
}
