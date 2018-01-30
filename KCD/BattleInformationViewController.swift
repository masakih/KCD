//
//  BattleInformationViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/11/30.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class BattleInformationViewController: NSViewController {
    
    private let notificationObserver = NotificationObserver()
    
    @objc private let battleManagedObjectContext = TemporaryDataStore.default.context
    
    @IBOutlet private var battleContoller: NSObjectController!
    @IBOutlet private weak var cellNumberField: NSTextField!
    
    override var nibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    private var battle: Battle? {
        didSet { updateProperties() }
    }
    @objc dynamic private var cellNumber: Int = 0
    private var battleCellNumber: Int = 0
    private var isBossCell: Bool = false
    private var deckId: Int = 0 {
        didSet {
            fleetName = ServerDataStore.default.deck(by: deckId)?.name
        }
    }
    private var fleetName: String?
    private var mapArea: Int?
    private var mapInfo: Int?
    private var areaNumber: String? {
        
        guard let mapInfo = self.mapInfo else { return nil }
        
        let mapArea: String
        switch self.mapArea {
        case let area? where area > 10: mapArea = "E"
        case let area?: mapArea = "\(area)"
        case .none: return nil
        }
        
        return "\(mapArea)-\(mapInfo)"
    }
    private var areaName: String? {
        
        guard let mapArea = self.mapArea else { return nil }
        guard let mapInfo = self.mapInfo else { return nil }
        
        return ServerDataStore.default.mapInfo(area: mapArea, no: mapInfo)?.name
    }
    
    @objc private var sortieString: String? {
        
        guard let fleetName = self.fleetName else { return nil }
        guard let areaName = self.areaName else { return nil }
        guard let areaNumber = self.areaNumber else { return nil }
        
        if battleCellNumber == 0 {
            
            return String(format: LocalizedStrings.sortieInfomation.string,
                          arguments: [fleetName, areaName, areaNumber])
        }
        if isBossCell {
            
            return String(format: LocalizedStrings.battleWithBOSS.string,
                          arguments: [fleetName, battleCellNumber as NSNumber, areaName, areaNumber])
        }
        
        return String(format: LocalizedStrings.battleInformation.string,
                      arguments: [fleetName, battleCellNumber as NSNumber, areaName, areaNumber])
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        notificationObserver
            .addObserver(forName: .NSManagedObjectContextObjectsDidChange,
                         object: TemporaryDataStore.default.context,
                         queue: .main) { notification in
                            
                            if let battle: Battle = notification.insertedManagedObjects().first {
                                
                                self.battle = battle
                            }
                            
                            if let _: Battle = notification.updatedManagedObjects().first {
                                
                                self.updateProperties()
                            }
                            
                            if let _: Battle = notification.deletedManagedObjects().first {
                                
                                self.battle = nil
                            }
        }
        
        #if DEBUG
            cellNumberField.isHidden = false
        #endif
    }
    
    private func updateProperties() {
        
        cellNumber = battle?.no ?? 0
        battleCellNumber = battle?.battleCell as? Int ?? 0
        isBossCell = battle?.isBossCell ?? false
        deckId = battle?.deckId ?? 0
        mapArea = battle?.mapArea
        mapInfo = battle?.mapInfo
        
        notifyChangeValue(forKey: #keyPath(sortieString))
    }
}
