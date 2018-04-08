//
//  DocksViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/25.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

protocol DockInformationUpdater: class {
    
    func update()
}

final class DocksViewController: MainTabVIewItemViewController {
    
    @objc let managedObjectContext = ServerDataStore.default.context
    let questListViewController = QuestListViewController()
    let battleInfoViewController = BattleInformationViewController()
    
    private var updaters: [DockInformationUpdater] = []
    
    @objc dynamic var nDock1Time: NSNumber?
    @objc dynamic var nDock2Time: NSNumber?
    @objc dynamic var nDock3Time: NSNumber?
    @objc dynamic var nDock4Time: NSNumber?
    
    @objc dynamic var nDock1ShipName: String?
    @objc dynamic var nDock2ShipName: String?
    @objc dynamic var nDock3ShipName: String?
    @objc dynamic var nDock4ShipName: String?
    
    @objc dynamic var kDock1Time: NSNumber?
    @objc dynamic var kDock2Time: NSNumber?
    @objc dynamic var kDock3Time: NSNumber?
    @objc dynamic var kDock4Time: NSNumber?
    
    @objc dynamic var deck2Time: NSNumber?
    @objc dynamic var deck3Time: NSNumber?
    @objc dynamic var deck4Time: NSNumber?
    
    @objc dynamic var mission2Name: String?
    @objc dynamic var mission3Name: String?
    @objc dynamic var mission4Name: String?
    
    @IBOutlet private weak var battleInformationViewPlaceholder: NSView!
    @IBOutlet private weak var questListViewPlaceholder: NSView!
    
    override var nibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupStatus()
        
        replace(view: battleInformationViewPlaceholder, with: battleInfoViewController)
        replace(view: questListViewPlaceholder, with: questListViewController)
    }
    
    private func setupStatus() {
                
        (2...4).forEach {
            
            createMissionSatusFuture(number: $0)
                .onSuccess { status in
                    
                    self.updaters += [status]
                    status.delegate = self
                }
                .onFailure { error in
                    
                    Logger.shared.log("\(error)")
            }
        }
        
        (1...4).forEach {
            
            createNyukyoDockStatusFuture(number: $0)
                .onSuccess { status in
                    
                    self.updaters += [status]
                    status.delegate = self
                }
                .onFailure { error in
                    
                    Logger.shared.log("\(error)")
            }
            
            createKenzoDockStatusFuture(number: $0)
                .onSuccess { status in
                    
                    self.updaters += [status]
                    status.delegate = self
                }
                .onFailure { error in
                    
                    Logger.shared.log("\(error)")
            }
        }
        
        AppDelegate.shared.addCounterUpdate {
            
            self.updaters.forEach { $0.update() }
        }
    }
}

extension DocksViewController: MissionStatusObserver {
    
    func didUpdate(state: MissionStatus) {
        
        switch state.number {
            
        case 2:
            deck2Time = state.time.map { $0 as NSNumber }
            mission2Name = state.name
            
        case 3:
            deck3Time = state.time.map { $0 as NSNumber }
            mission3Name = state.name
            
        case 4:
            deck4Time = state.time.map { $0 as NSNumber }
            mission4Name = state.name
            
        default: ()
            
        }
    }
}

extension DocksViewController: NyukyoDockStatusObserver {
    
    func didUpdate(state: NyukyoDockStatus) {
        
        switch state.number {
            
        case 1:
            nDock1Time = state.time.map { $0 as NSNumber }
            nDock1ShipName = state.name
            
        case 2:
            nDock2Time = state.time.map { $0 as NSNumber }
            nDock2ShipName = state.name
            
        case 3:
            nDock3Time = state.time.map { $0 as NSNumber }
            nDock3ShipName = state.name
            
        case 4:
            nDock4Time = state.time.map { $0 as NSNumber }
            nDock4ShipName = state.name
            
        default: ()
            
        }
    }
}

extension DocksViewController: KenzoDockStatusObserver {
    
    func didUpdate(state: KenzoDockStatus) {
        
        switch state.number {
            
        case 1:
            kDock1Time = state.time.map { $0 as NSNumber }
        
        case 2:
            kDock2Time = state.time.map { $0 as NSNumber }
            
        case 3:
            kDock3Time = state.time.map { $0 as NSNumber }
            
        case 4:
            kDock4Time = state.time.map { $0 as NSNumber }
            
        default: ()
            
        }
    }
}
