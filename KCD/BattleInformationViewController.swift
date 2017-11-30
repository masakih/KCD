//
//  BattleInformationViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/11/30.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class BattleInformationViewController: NSViewController {
    
    
    deinit {
        ["selection", "selection.no", "content.battleCell"]
            .forEach { battleContoller.removeObserver(self, forKeyPath: $0) }
    }
    
    @objc let battleManagedObjectContext = TemporaryDataStore.default.context
    
    @IBOutlet var battleContoller: NSObjectController!
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
        
        ["selection", "selection.no", "content.battleCell"]
            .forEach { battleContoller.addObserver(self, forKeyPath: $0, context: nil) }
        
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
    
}
