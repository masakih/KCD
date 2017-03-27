//
//  StrengthenListViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/25.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate let resourceName = "EnhancementListItem2"
fileprivate let resourceExtension = "plist"


fileprivate struct FilterCategories {
    static let allType: [EquipmentType] = (1...100).flatMap { EquipmentType(rawValue: $0) }
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
                                             .SubmarineEquipment]
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

class StrengthenListViewController: MainTabVIewItemViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    
    dynamic var itemList: Any { return filteredItems as Any }
    dynamic var offsetDay: Int = 0 {
        didSet { buildList() }
    }
    dynamic var filterType: Int = 0 {
        didSet {
            if let t = FilterCategories.FilterType(rawValue: filterType) {
                showsTypes = FilterCategories(type: t).categories
            } else {
                showsTypes = FilterCategories.allType
            }
            buildList()
        }
    }
    override var nibName: String! {
        return "StrengthenListViewController"
    }
    
    fileprivate var filteredItems: [StrengthenListItem] = [] {
        willSet { willChangeValue(forKey: #keyPath(itemList)) }
        didSet { didChangeValue(forKey: #keyPath(itemList)) }
    }
    
    private let notifier = PeriodicNotifier(hour: 0, minutes: 0)
    private let plistDownloadNotifier = PeriodicNotifier(hour: 23, minutes: 55)
    private let downloader = EnhancementListItemDownloader()
    private var equipmentStrengthenList: [EnhancementListItem] = []
    private var showsTypes: [EquipmentType] = FilterCategories.allType
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension),
            let data = try? Data(contentsOf: url) {
            guard let array = NSKeyedUnarchiver.unarchiveObject(with: data) as? [EnhancementListItem]
                else {
                    print("\(resourceName).\(resourceExtension) not found.")
                    return
            }
            equipmentStrengthenList = array
            buildList()
        }
        
        let nc = NotificationCenter.default
        nc.addObserver(forName: .Periodic, object: notifier, queue: nil) { [weak self] _ in
            guard let `self` = self else { return }
            self.buildList()
        }
        nc.addObserver(forName: .Periodic, object: plistDownloadNotifier, queue: nil) { [weak self] _ in
            guard let `self` = self else { return }
            self.downloadPList()
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
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.equipmentStrengthenList = items
                self.buildList()
            }
        }
    }
    private func allItemList() -> [EnhancementListItem] {
        var allIdentifier: [String] = []
        var dict: [String: EnhancementListItem] = [:]
        equipmentStrengthenList.forEach {
            var item = dict[$0.identifier]
            if item == nil {
                item = $0.replace(weekday: 10)
                dict[$0.identifier] = item
                allIdentifier.append($0.identifier)
            }
            var secondShips = item?.secondsShipNames
            secondShips?.append(contentsOf: $0.secondsShipNames)
            secondShips?.uniqueInPlace()
            dict[$0.identifier] = item?.replace(secondsShipNames: secondShips)
        }
        
        return allIdentifier.flatMap { dict[$0] }
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

fileprivate class EnhancementListItemDownloader: NSObject, URLSessionDownloadDelegate {
    override init() {
        super.init()
        
        plistDownloadQueue = OperationQueue()
        plistDownloadQueue.name = "StrengthenListViewControllerPlistDownloadQueue"
        plistDownloadQueue.maxConcurrentOperationCount = 1
        plistDownloadQueue.qualityOfService = .background
        let configuration = URLSessionConfiguration.default
        plistDownloadSession = URLSession(configuration: configuration,
                                          delegate: self,
                                          delegateQueue: plistDownloadQueue)
    }
    
    private var plistDownloadSession: URLSession!
    private var plistDownloadQueue: OperationQueue!
    private var plistDownloadTask: URLSessionDownloadTask?
    private var finishOperation: (([EnhancementListItem]) -> Void)?
    
    func download(completeHandler: @escaping ([EnhancementListItem]) -> Void) {
        if let _ = plistDownloadTask { return }
        // swiftlint:disable:next line_length
        guard let plistURL = URL(string: "http://git.osdn.jp/view?p=kcd/KCD.git;a=blob;f=KCD/\(resourceName).\(resourceExtension);hb=HEAD")
            else { return }
        
        finishOperation = completeHandler
        plistDownloadTask = plistDownloadSession.downloadTask(with: plistURL)
        plistDownloadTask?.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        plistDownloadTask = nil
        guard let data = try? Data(contentsOf: location, options: []),
            let list = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [EnhancementListItem]
            else { return }
        finishOperation?(list)
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        plistDownloadTask = nil
    }
}
