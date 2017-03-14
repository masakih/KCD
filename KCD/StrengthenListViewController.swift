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

class StrengthenListViewController: MainTabVIewItemViewController {
    private let notifier = PeriodicNotifier(hour: 0, minutes: 0)
    private let plistDownloadNotifier = PeriodicNotifier(hour: 23, minutes: 55)
        
    @IBOutlet weak var tableView: NSTableView!
    
    dynamic var itemList: [EnhancementListItem] = []
    dynamic var offsetDay: Int = 0 {
        didSet { buildList() }
    }
    override var nibName: String! {
        return "StrengthenListViewController"
    }
    private let downloader = EnhancementListItemDownloader()
    private var equipmentStrengthenList: [EnhancementListItem] = []
    
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
            
            #if DEBUG
//                downloadPList()
            #else
                downloadPList()
            #endif
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
    }
    private func buildList() {
        var newList: [EnhancementListItem] = {
            if offsetDay == -1 { return allItemList() }
            
            let currentDay = NSCalendar.current.dateComponents([.weekday], from: Date())
            var targetWeekday = currentDay.weekday! + offsetDay
            if targetWeekday > 7 { targetWeekday = 1 }
            return equipmentStrengthenList.filter { $0.weekday == targetWeekday }
        }()
        
        var type: EquipmentType = .unknown
        let group: [(EquipmentType, Int)] = newList.enumerated().flatMap {
            if type != $0.element.equipmentType {
                type = $0.element.equipmentType
                return (type, $0.offset)
            }
            return nil
        }
        let t = SlotItemEquipTypeTransformer()
        let prototype = newList[0]
        group.reversed().forEach {
            let item = prototype.replace(identifier: t.transformedValue($0.0.rawValue) as? String,
                                         equipmentType: .unknown)
            newList.insert(item, at: $0.1)
        }
        itemList = newList
    }
    private func downloadPList() {
        downloader.download { [weak self] (array) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.equipmentStrengthenList = array
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
        let item = itemList[row]
        let identifier = (item.equipmentType == .unknown) ? "GroupCell" : "ItemCell"
        return tableView.make(withIdentifier: identifier, owner: nil)
    }
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        return (itemList[row].equipmentType == .unknown)
    }
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return (itemList[row].equipmentType == .unknown) ? 23.0 : 103.0
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
    
    func download(using block: @escaping ([EnhancementListItem]) -> Void) {
        if let _ = plistDownloadTask { return }
        // swiftlint:disable:next line_length
        guard let plistURL = URL(string: "http://git.osdn.jp/view?p=kcd/KCD.git;a=blob;f=KCD/\(resourceName).\(resourceExtension);hb=HEAD")
            else { return }
        
        finishOperation = block
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
