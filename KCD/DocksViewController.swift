//
//  DocksViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/25.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

class DocksViewController: MainTabVIewItemViewController {
    deinit {
        [("deck2Time", "mission2Name"),
         ("deck3Time", "mission3Name"),
         ("deck4Time", "mission4Name")]
            .forEach {
                unbind($0.0)
                unbind($0.1)
        }
        [("nDock1Time", "nDock1ShipName"),
         ("nDock2Time", "nDock2ShipName"),
         ("nDock3Time", "nDock3ShipName"),
         ("nDock4Time", "nDock4ShipName")]
            .forEach {
                unbind($0.0)
                unbind($0.1)
        }
        ["kDock1Time", "kDock2Time", "kDock3Time", "kDock4Time"]
            .forEach { unbind($0) }
        
        ["selection", "selection.no", "content.battleCell"]
            .forEach {
            battleContoller.removeObserver(self, forKeyPath: $0)
        }
    }
    
    let managedObjectContext = ServerDataStore.default.managedObjectContext
    let battleManagedObjectController = TemporaryDataStore.default.managedObjectContext
    let questListViewController = QuestListViewController()
    
    let missionStates = (2...4).flatMap { MissionStatus(number: $0) }
    let ndockStatus = (1...4).flatMap { NyukyoDockStatus(number: $0) }
    let kdockStatus = (1...4).flatMap { KenzoDockStatus(number: $0) }
    
    var nDock1Time: NSNumber? = nil
    var nDock2Time: NSNumber? = nil
    var nDock3Time: NSNumber? = nil
    var nDock4Time: NSNumber? = nil
    
    var nDock1ShipName: String? = nil
    var nDock2ShipName: String? = nil
    var nDock3ShipName: String? = nil
    var nDock4ShipName: String? = nil
    
    var kDock1Time: NSNumber? = nil
    var kDock2Time: NSNumber? = nil
    var kDock3Time: NSNumber? = nil
    var kDock4Time: NSNumber? = nil
    
    var deck2Time: NSNumber? = nil
    var deck3Time: NSNumber? = nil
    var deck4Time: NSNumber? = nil
    
    var mission2Name: String? = nil
    var mission3Name: String? = nil
    var mission4Name: String? = nil
    
    @IBOutlet var battleContoller: NSObjectController!
    @IBOutlet weak var questListViewPlaceholder: NSView!
    @IBOutlet weak var cellNumberField: NSTextField!
    
    override var nibName: String! {
        return "DocksViewController"
    }
    
    var battle: Battle? {
        return TemporaryDataStore.default.battle()
    }
    
    var cellNumber: Int {
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
        return ServerDataStore.default.deck(byId: deckId)?.name
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
        guard let mapArea = battleContoller.value(forKeyPath: "content.mapArea") as? Int,
            let mapInfo = battleContoller.value(forKeyPath: "content.mapInfo") as? Int
            else { return nil }
        
        return ServerDataStore.default.mapInfo(area: mapArea, no: mapInfo)?.name
    }
    var sortieString: String? {
        guard let fleetName = self.fleetName,
            let areaName = self.areaName,
            let areaNumber = self.areaNumber
            else { return nil }
        if battleCellNumber == 0 {
            let format = NSLocalizedString("%@ in sortie into %@ (%@)", comment: "Sortie")
            return String(format: format, arguments: [fleetName, areaName, areaNumber])
        }
        if isBossCell {
            let format = NSLocalizedString("%@ battle against the enemy main fleet at %@ war zone in %@ (%@) now", comment: "Sortie")
            return String(format: format, arguments: [fleetName, battleCellNumber as NSNumber, areaName, areaNumber])
        }
        let format = NSLocalizedString("%@ battle at %@ war zone in %@ (%@) now", comment: "Sortie")
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
            willChangeValue(forKey: "sortieString")
            didChangeValue(forKey: "sortieString")
            return
        }
        if keyPath == "selection.no" {
            willChangeValue(forKey: "cellNumber")
            didChangeValue(forKey: "cellNumber")
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    private func setupStatus() {
        let missionKeys = [
            ("deck2Time", "mission2Name"),
            ("deck3Time", "mission3Name"),
            ("deck4Time", "mission4Name")
        ]
        zip(missionStates, missionKeys).forEach {
            bind($0.1.0, to: $0.0, withKeyPath: "time", options: nil)
            bind($0.1.1, to: $0.0, withKeyPath: "name", options: nil)
        }
        
        let ndockKeys = [
            ("nDock1Time", "nDock1ShipName"),
            ("nDock2Time", "nDock2ShipName"),
            ("nDock3Time", "nDock3ShipName"),
            ("nDock4Time", "nDock4ShipName")
        ]
        zip(ndockStatus, ndockKeys).forEach {
            bind($0.1.0, to: $0.0, withKeyPath: "time", options: nil)
            bind($0.1.1, to: $0.0, withKeyPath: "name", options: nil)
        }
        
        let kdockKeys = ["kDock1Time", "kDock2Time", "kDock3Time", "kDock4Time"]
        zip(kdockStatus, kdockKeys).forEach {
            bind($0.1, to: $0.0, withKeyPath: "time", options: nil)
        }
    }
    
}
