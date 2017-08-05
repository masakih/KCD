//
//  ShipViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/25.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate enum ViewType: Int {
    
    case exp
    case power
    case power2
    case power3
}

final class ShipViewController: MainTabVIewItemViewController {
    
    let managedObjectContext = ServerDataStore.default.context
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet var shipController: NSArrayController!
    @IBOutlet var expTableView: NSScrollView!
    @IBOutlet var powerTableView: NSScrollView!
    @IBOutlet var power2TableView: NSScrollView!
    @IBOutlet var power3TableView: NSScrollView!
    @IBOutlet weak var standardDeviationField: NSTextField!
    
    override var nibName: String! {
        
        return "ShipViewController"
    }
    
    override var hasShipTypeSelector: Bool { return true }
    override var selectedShipType: ShipType {
        
        didSet {
            shipController.filterPredicate = shipTypePredicte
            shipController.rearrangeObjects()
        }
    }
    
    var standardDeviation: Double {
        
        guard let ships = shipController.arrangedObjects as? [Ship],
            !ships.isEmpty,
            let avg = shipController.value(forKeyPath: "arrangedObjects.@avg.lv") as? Double
            else { return 0.0 }
        
        let total = ships.reduce(0.0) {
            
            let delta = Double($1.lv) - avg
            
            return $0 + delta * delta
        }
        
        return sqrt(total / Double(ships.count))
    }
    
    fileprivate weak var currentTableView: NSView?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        currentTableView = expTableView
        
        do {
            
            try shipController.fetch(with: nil, merge: true)
            
        } catch {
            
            fatalError("ShipViewController: can not fetch. \(error)")
            
        }
        
        shipController.sortDescriptors = UserDefaults.standard[.shipviewSortDescriptors]
        shipController.addObserver(self, forKeyPath: NSSortDescriptorsBinding, context: nil)
        shipController.addObserver(self, forKeyPath: "arrangedObjects", context: nil)
        
        let tableViews = [expTableView, powerTableView, power2TableView, power3TableView]
        tableViews
            .forEach {
                
                NotificationCenter.default
                    .addObserver(forName: .NSScrollViewDidEndLiveScroll, object: $0, queue: nil) {
                        
                        guard let target = $0.object as? NSScrollView
                            else { return }
                        
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == NSSortDescriptorsBinding {
            
            UserDefaults.standard[.shipviewSortDescriptors] = shipController.sortDescriptors
            
            return
        }
        
        if keyPath == "arrangedObjects" {
            
            notifyChangeValue(forKey: "standardDeviation")
            
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    fileprivate func showView(with type: ViewType) {
        
        let newSelection: NSView = {
            
            switch type {
            case .exp: return expTableView
            case .power: return powerTableView
            case .power2: return power2TableView
            case .power3: return power3TableView
            }
        }()
        
        if currentTableView == newSelection { return }
        
        guard let tableView = currentTableView
            else { return }
        
        newSelection.frame = tableView.frame
        newSelection.autoresizingMask = tableView.autoresizingMask
        view.replaceSubview(tableView, with: newSelection)
        view.window?.makeFirstResponder(newSelection)
        currentTableView = newSelection
    }
    
    private func tag(_ sender: AnyObject?) -> Int {
        
        guard let sender = sender
            else { return -1 }
        
        if let control = sender as? NSSegmentedControl,
            let cell = sender.cell as? NSSegmentedCell {
            
            return cell.tag(forSegment: control.selectedSegment)
        }
        
        if let control = sender as? NSControl {
            
            return control.tag
        }
        
        return -1
    }
    
    @IBAction func changeView(_ sender: AnyObject?) {
        
        ViewType(rawValue: tag(sender)).map { showView(with: $0) }
    }
}

extension ShipViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let identifier = tableColumn?.identifier
            else { return nil }
        
        return tableView.make(withIdentifier: identifier, owner: nil)
    }
}
