//
//  ShipViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/25.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

private enum ViewType: Int {
    
    case exp
    case power
    case power2
    case power3
}

final class ShipViewController: MainTabVIewItemViewController {
    
    @objc let managedObjectContext = ServerDataStore.default.context
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet var shipController: NSArrayController!
    @IBOutlet var expTableView: NSScrollView!
    @IBOutlet var powerTableView: NSScrollView!
    @IBOutlet var power2TableView: NSScrollView!
    @IBOutlet var power3TableView: NSScrollView!
    @IBOutlet weak var standardDeviationField: NSTextField!
    
    private var sortDescriptorsObservation: NSKeyValueObservation?
    private var arrangedObjectsObservation: NSKeyValueObservation?
    
    override var nibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    override var hasShipTypeSelector: Bool { return true }
    override var selectedShipType: ShipTabType {
        
        didSet {
            shipController.filterPredicate = shipTypePredicte
            shipController.rearrangeObjects()
        }
    }
    
    @objc var standardDeviation: Double {
        
        guard let ships = shipController.arrangedObjects as? [Ship], !ships.isEmpty else { return 0.0 }
        guard let avg = shipController.value(forKeyPath: "arrangedObjects.@avg.lv") as? Double else { return 0.0 }
        
        let total = ships.reduce(0.0) {
            
            let delta = Double($1.lv) - avg
            
            return $0 + delta * delta
        }
        
        return sqrt(total / Double(ships.count))
    }
    
    private weak var currentTableView: NSView?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        currentTableView = expTableView
        
        do {
            
            try shipController.fetch(with: nil, merge: true)
            
        } catch {
            
            fatalError("ShipViewController: can not fetch. \(error)")
            
        }
        
        shipController.sortDescriptors = UserDefaults.standard[.shipviewSortDescriptors]
        
        sortDescriptorsObservation = shipController.observe(\NSArrayController.sortDescriptors) { [weak self] _, _ in
            
            UserDefaults.standard[.shipviewSortDescriptors] = self?.shipController.sortDescriptors ?? []
        }
        arrangedObjectsObservation = shipController.observe(\NSArrayController.arrangedObjects) { [weak self] _, _ in
            
            self?.notifyChangeValue(forKey: #keyPath(standardDeviation))
        }
        
        let tableViews = [expTableView, powerTableView, power2TableView, power3TableView]
        tableViews
            .forEach {
                
                NotificationCenter.default
                    .addObserver(forName: NSScrollView.didEndLiveScrollNotification, object: $0, queue: nil) {
                        
                        guard let target = $0.object as? NSScrollView else { return }
                        
                        let visibleRect = target.documentVisibleRect
                        tableViews
                            .filter { $0 != target }
                            .forEach { $0?.documentView?.scrollToVisible(visibleRect) }
                }
        }
        #if DEBUG
            standardDeviationField.isHidden = false
        #endif
    }
    
    private func showView(with type: ViewType) {
        
        let newSelection: NSView = {
            
            switch type {
            case .exp: return expTableView
            case .power: return powerTableView
            case .power2: return power2TableView
            case .power3: return power3TableView
            }
        }()
        
        if currentTableView == newSelection { return }
        
        guard let tableView = currentTableView else { return }
        
        newSelection.frame = tableView.frame
        newSelection.autoresizingMask = tableView.autoresizingMask
        view.replaceSubview(tableView, with: newSelection)
        view.window?.makeFirstResponder(newSelection)
        currentTableView = newSelection
    }
    
    private func tag(_ sender: AnyObject?) -> Int {
        
        switch sender {
            
        case let segmented as NSSegmentedControl:
            let cell = segmented.cell as? NSSegmentedCell
            
            return cell?.tag(forSegment: segmented.selectedSegment) ?? -1
            
        case let control as NSControl:
            return control.tag
            
        default:
            return -1
        }
    }
    
    @IBAction func changeView(_ sender: AnyObject?) {
        
        ViewType(rawValue: tag(sender)).map(showView)
    }
}

extension ShipViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let identifier = tableColumn?.identifier else { return nil }
        
        return tableView.makeView(withIdentifier: identifier, owner: nil)
    }
}
