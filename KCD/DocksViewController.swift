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
        
        ["selection", "selection.no", "content.battleCell"]
            .forEach {
            battleContoller.removeObserver(self, forKeyPath: $0)
        }
    }
    
    @objc let managedObjectContext = ServerDataStore.default.context
    @objc let battleManagedObjectController = TemporaryDataStore.default.context
    let questListViewController = QuestListViewController()
    
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
    
    @IBOutlet var battleContoller: NSObjectController!
    @IBOutlet weak var questListViewPlaceholder: NSView!
    @IBOutlet weak var cellNumberField: NSTextField!
    
    override var nibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    var battle: Battle? {
        
        return TemporaryDataStore.default.battle()
    }
    
    @objc var cellNumber: Int {
        
        return battleContoller.value(forKeyPath: "content.no") as? Int ?? 0
    }
    
    var battleCellNumber: Int {
        
        return battleContoller.value(forKeyPath: "content.battleCell") as? Int ?? 0
    }
    
    var isBossCell: Bool {
        
        return battleContoller.value(forKeyPath: "content.isBossCell") as? Bool ?? false
    }
    
    var fleetName: String? {
        
        guard let deckId = battleContoller.value(forKeyPath: "content.deckId") as? Int else { return nil }
        
        return ServerDataStore.default.deck(by: deckId)?.name
    }
    
    var areaNumber: String? {
        
        let mapArea: String = {
            
            guard let mapArea = battleContoller.value(forKeyPath: "content.mapArea") as? Int else { return "" }
            
            if mapArea > 10 { return "E" }
            
            return "\(mapArea)"
        }()
        
        guard mapArea != "" else { return nil }
        
        guard let mapInfo = battleContoller.value(forKeyPath: "content.mapInfo") as? Int else { return "" }
        
        return "\(mapArea)-\(mapInfo)"
    }
    
    var areaName: String? {
        
        guard let mapArea = battleContoller.value(forKeyPath: "content.mapArea") as? Int else { return nil }
        guard let mapInfo = battleContoller.value(forKeyPath: "content.mapInfo") as? Int else { return nil }
        
        return ServerDataStore.default.mapInfo(area: mapArea, no: mapInfo)?.name
    }
    
    @objc var sortieString: String? {
        
        guard let fleetName = self.fleetName,
            let areaName = self.areaName,
            let areaNumber = self.areaNumber else { return nil }
        
        if battleCellNumber == 0 {
            
            let format = LocalizedStrings.sortieInfomation.string
            
            return String(format: format, arguments: [fleetName, areaName, areaNumber])
        }
        if isBossCell {
            
            let format = LocalizedStrings.battleWithBOSS.string
            
            return String(format: format, arguments: [fleetName, battleCellNumber as NSNumber, areaName, areaNumber])
        }
        
        let format = LocalizedStrings.battleInformation.string
        
        return String(format: format, arguments: [fleetName, battleCellNumber as NSNumber, areaName, areaNumber])
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupStatus()
        
        AppDelegate.shared.addCounterUpdate {
            
            self.missionStates.forEach { $0.update() }
            self.kdockStatus.forEach { $0.update() }
            self.ndockStatus.forEach { $0.update() }
        }
        
        questListViewController.view.frame = questListViewPlaceholder.frame
        questListViewController.view.autoresizingMask = questListViewPlaceholder.autoresizingMask
        questListViewPlaceholder.superview?.replaceSubview(questListViewPlaceholder, with: questListViewController.view)
        
        ["selection", "selection.no", "content.battleCell"]
            .forEach {
                battleContoller.addObserver(self, forKeyPath: $0, context: nil)
        }
        
        #if DEBUG
            cellNumberField.isHidden = false
        #endif
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "selection" || keyPath == "content.battleCell" {
            
            notifyChangeValue(forKey: #keyPath(sortieString))
            
            return
        }
        
        if keyPath == "selection.no" {
            
            notifyChangeValue(forKey: #keyPath(cellNumber))
            
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
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
