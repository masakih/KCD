//
//  DocksViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/25.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class DocksViewController: MainTabVIewItemViewController {
    
    deinit {
        
        [NSBindingName(#keyPath(deck2Time)), NSBindingName(#keyPath(mission2Name)),
         NSBindingName(#keyPath(deck3Time)), NSBindingName(#keyPath(mission3Name)),
         NSBindingName(#keyPath(deck4Time)), NSBindingName(#keyPath(mission4Name))]
            .forEach(unbind)
        [NSBindingName(#keyPath(nDock1Time)), NSBindingName(#keyPath(nDock1ShipName)),
         NSBindingName(#keyPath(nDock2Time)), NSBindingName(#keyPath(nDock2ShipName)),
         NSBindingName(#keyPath(nDock3Time)), NSBindingName(#keyPath(nDock3ShipName)),
         NSBindingName(#keyPath(nDock4Time)), NSBindingName(#keyPath(nDock4ShipName))]
            .forEach(unbind)
        [NSBindingName(#keyPath(kDock1Time)), NSBindingName(#keyPath(kDock2Time)),
         NSBindingName(#keyPath(kDock3Time)), NSBindingName(#keyPath(kDock4Time))]
            .forEach(unbind)
    }
    
    @objc let managedObjectContext = ServerDataStore.default.context
    let questListViewController = QuestListViewController()
    let battleInfoViewController = BattleInformationViewController()
    
    let missionStates = (2...4).flatMap { MissionStatus(number: $0) }
    let ndockStatus = (1...4).flatMap { NyukyoDockStatus(number: $0) }
    let kdockStatus = (1...4).flatMap { KenzoDockStatus(number: $0) }
    
    @objc var nDock1Time: NSNumber?
    @objc var nDock2Time: NSNumber?
    @objc var nDock3Time: NSNumber?
    @objc var nDock4Time: NSNumber?
    
    @objc var nDock1ShipName: String?
    @objc var nDock2ShipName: String?
    @objc var nDock3ShipName: String?
    @objc var nDock4ShipName: String?
    
    @objc var kDock1Time: NSNumber?
    @objc var kDock2Time: NSNumber?
    @objc var kDock3Time: NSNumber?
    @objc var kDock4Time: NSNumber?
    
    @objc var deck2Time: NSNumber?
    @objc var deck3Time: NSNumber?
    @objc var deck4Time: NSNumber?
    
    @objc var mission2Name: String?
    @objc var mission3Name: String?
    @objc var mission4Name: String?
    
    @IBOutlet weak var battleInformationViewPlaceholder: NSView!
    @IBOutlet weak var questListViewPlaceholder: NSView!
    
    override var nibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupStatus()
        
        AppDelegate.shared.addCounterUpdate {
            
            self.missionStates.forEach { $0.update() }
            self.kdockStatus.forEach { $0.update() }
            self.ndockStatus.forEach { $0.update() }
        }
        
        replace(view: battleInformationViewPlaceholder, with: battleInfoViewController)
        replace(view: questListViewPlaceholder, with: questListViewController)
    }
    
    private func setupStatus() {
        
        let missionKeys = [
            (#keyPath(deck2Time), #keyPath(mission2Name)),
            (#keyPath(deck3Time), #keyPath(mission3Name)),
            (#keyPath(deck4Time), #keyPath(mission4Name))
        ]
        zip(missionStates, missionKeys).forEach {
            
            bind(NSBindingName(rawValue: $0.1.0), to: $0.0, withKeyPath: #keyPath(MissionStatus.time), options: nil)
            bind(NSBindingName(rawValue: $0.1.1), to: $0.0, withKeyPath: #keyPath(MissionStatus.name), options: nil)
        }
        
        let ndockKeys = [
            (#keyPath(nDock1Time), #keyPath(nDock1ShipName)),
            (#keyPath(nDock2Time), #keyPath(nDock2ShipName)),
            (#keyPath(nDock3Time), #keyPath(nDock3ShipName)),
            (#keyPath(nDock4Time), #keyPath(nDock4ShipName))
        ]
        zip(ndockStatus, ndockKeys).forEach {
            
            bind(NSBindingName(rawValue: $0.1.0), to: $0.0, withKeyPath: #keyPath(NyukyoDockStatus.time), options: nil)
            bind(NSBindingName(rawValue: $0.1.1), to: $0.0, withKeyPath: #keyPath(NyukyoDockStatus.name), options: nil)
        }
        
        let kdockKeys = [#keyPath(kDock1Time), #keyPath(kDock2Time), #keyPath(kDock3Time), #keyPath(kDock4Time)]
        zip(kdockStatus, kdockKeys).forEach {
            
            bind(NSBindingName(rawValue: $0.1), to: $0.0, withKeyPath: #keyPath(KenzoDockStatus.time), options: nil)
        }
    }
    
}
