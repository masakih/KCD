//
//  StrengthenListViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/25.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

private let resourceName = "EnhancementListItem2"
private let resourceExtension = "plist"


private struct FilterCategories {
    
    static let allType: [EquipmentType] = (1...100).compactMap { EquipmentType(rawValue: $0) }
    static let canonType: [EquipmentType] = [.smallCaliberMainGun, .mediumCaliberMainGun,
                                             .largeCaliberMainGun, .largeCaliberMainGunII]
    static let torpedoType: [EquipmentType] = [.secondaryGun, .torpedo,
                                               .antiAircraftGun, .antiSunmrinerSercher, .submarinTorpedo,
                                               .largeSonar]
    static let airplaneType: [EquipmentType] = [.fighter, .bomber, .attacker, .searcher,
                                                .airplaneSearcher, .airplaneBomber,
                                                .largeAirplane, .airplaneFighter,
                                                .landAttecker, .localFighter,
                                                .jetFighter, .jetBomber,
                                                .jetAttacker, .jetSearcher,
                                                .searcherII]
    static let radarType: [EquipmentType] = [.smallRadar, .largeRadar,
                                             .sonar, .depthCharge,
                                             .submarineEquipment]
    static let otherType: [EquipmentType] = {
        return allType
            .filter { !canonType.contains($0) }
            .filter { !torpedoType.contains($0) }
            .filter { !airplaneType.contains($0) }
            .filter { !radarType.contains($0) }
    }()
    
    enum FilterType: Int {
        
        case all = 0
        case canon
        case torpedo
        case airplane
        case radar
        case other
    }
    
    let categories: [EquipmentType]
    
    init(type: FilterType) {
        
        switch type {
        case .all: categories = FilterCategories.allType
        case .canon: categories = FilterCategories.canonType
        case .torpedo: categories = FilterCategories.torpedoType
        case .airplane: categories = FilterCategories.airplaneType
        case .radar: categories = FilterCategories.radarType
        case .other: categories = FilterCategories.otherType
        }
    }
}

final class StrengthenListViewController: MainTabVIewItemViewController {
    
    @IBOutlet private weak var tableView: NSTableView!
    
    @objc dynamic var itemList: Any { return filteredItems as Any }
    @objc dynamic var offsetDay: Int = 0 {
        
        didSet { buildList() }
    }
    @objc dynamic var filterType: Int = 0 {
        
        didSet {
            if let t = FilterCategories.FilterType(rawValue: filterType) {
                
                showsTypes = FilterCategories(type: t).categories
                
            } else {
                
                showsTypes = FilterCategories.allType
            }
            buildList()
        }
    }
    
    override var nibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    private var filteredItems: [StrengthenListItem] = [] {
        
        willSet { willChangeValue(forKey: #keyPath(itemList)) }
        didSet { didChangeValue(forKey: #keyPath(itemList)) }
    }
    
    private let itemListBuildNotifier = PeriodicNotifier(hour: 0, minutes: 0)
    private let plistDownloadNotifier = PeriodicNotifier(hour: 23, minutes: 55)
    private let downloader = EnhancementListItemDownloader(name: resourceName, extension: resourceExtension)
    private var equipmentStrengthenList: [EnhancementListItem] = []
    private var showsTypes: [EquipmentType] = FilterCategories.allType
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension),
            let data = try? Data(contentsOf: url) {
            
            guard let array = NSKeyedUnarchiver.unarchiveObject(with: data) as? [EnhancementListItem] else {
                
                return Logger.shared.log("\(resourceName).\(resourceExtension) not found.")
            }
            
            equipmentStrengthenList = array
            buildList()
        }
        
        let nc = NotificationCenter.default
        nc.addObserver(forName: .Periodic, object: itemListBuildNotifier, queue: nil) { [weak self] _ in
            
            self?.buildList()
        }
        
        nc.addObserver(forName: .Periodic, object: plistDownloadNotifier, queue: nil) { [weak self] _ in
            
            self?.downloadPList()
        }
        
        #if DEBUG
//          downloadPList()
        #else
            downloadPList()
        #endif
    }
    
    private func weekdayFiltered() -> [EnhancementListItem] {
        
        if offsetDay == -1 { return allItemList() }
        
        let currentDay = NSCalendar.current.dateComponents([.weekday], from: Date())
        var targetWeekday = currentDay.weekday! + offsetDay
        if targetWeekday > 7 { targetWeekday = 1 }
        
        return equipmentStrengthenList.filter { $0.weekday == targetWeekday }
    }
    
    private func convert(items: [EnhancementListItem]) -> [StrengthenListItem] {
        
        guard let item = items.first else { return [] }
        
        let group: StrengthenListItem = StrengthenListGroupItem(type: item.equipmentType)
        let items: [StrengthenListItem] = items.map(StrengthenListEnhancementItem.init(item:))
        
        return [group] + items
    }
    
    private func buildList() {
        
        let filtered = weekdayFiltered()
        filteredItems = filtered
            .map { $0.equipmentType }
            .unique()
            .filter { showsTypes.contains($0) }
            .map { type in filtered.filter { $0.equipmentType == type } }
            .flatMap(convert)
    }
    
    private func downloadPList() {
        
        downloader.download { [weak self] items in
            
            DispatchQueue.main.async {
                
                self?.equipmentStrengthenList = items
                self?.buildList()
            }
        }
    }
    
    private func packSecondShipName(_ items: [EnhancementListItem]) -> [String] {
        
        return items.flatMap { $0.secondsShipNames }.unique()
    }
    
    private func allItemList() -> [EnhancementListItem] {
        
        return equipmentStrengthenList
            .map { $0.identifier }
            .unique()
            .map { identifier in equipmentStrengthenList.filter { $0.identifier == identifier } }
            .compactMap { $0.first?.replace(secondsShipNames: packSecondShipName($0)) }
    }
}

extension StrengthenListViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let item = filteredItems[row]
        return item.cellType.makeCellWithItem(item: item, tableView: tableView, owner: nil)
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        
        return filteredItems[row] is StrengthenListGroupItem
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        let item = filteredItems[row]
        
        return item.cellType.estimateCellHeightForItem(item: item, tableView: tableView)
    }
}
