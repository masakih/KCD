//
//  AirBaseWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/22.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

class AirBaseWindowController: NSWindowController {
    let managedObjectContext = ServerDataStore.default.managedObjectContext
    
    @IBOutlet var areaMatrix: NSMatrix!
    @IBOutlet var squadronTab: NSSegmentedControl!
    @IBOutlet var planesTable: NSTableView!
    @IBOutlet var airBaseController: NSArrayController!
    
    override var windowNibName: String! {
        return "AirBaseWindowController"
    }
    
    dynamic var areaId: Int = 0 {
        didSet {
            updatePredicate()
            updatePlaneSegment()
        }
    }
    dynamic var rId: Int = 0 {
        didSet {
            updatePredicate()
            updatePlaneSegment()
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        rId = 1
        
        airBaseController.addObserver(self, forKeyPath: "content", context: nil)
        
        updateAreaRadio()
        updatePlaneSegment()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "content" else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        updateAreaRadio()
        updatePlaneSegment()
    }
    
    private func updateAreaRadio() {
        guard let content = airBaseController.content as? [KCAirBase]
            else { return }
        let areas = content
            .flatMap { $0.area_id }
            .unique()
            .sorted(by: <)
        
        let cellCount = areaMatrix.numberOfRows * areaMatrix.numberOfColumns
        if areas.count != cellCount {
            let diff = areas.count - areaMatrix.numberOfColumns
            while areas.count != areaMatrix.numberOfColumns {
                if diff < 0 {
                    areaMatrix.removeColumn(0)
                } else {
                    areaMatrix.addColumn()
                }
            }
        }
        
        if areaMatrix.numberOfColumns == 0 {
            areaMatrix.addColumn()
            let areaCell = areaMatrix.cell(atRow: 0, column: 0)
            areaCell?.title = ""
            areaCell?.tag = -10_000
            
            areaMatrix.isEnabled = false
        } else {
            areaMatrix.isEnabled = true
        }
        
        let t = AreaNameTransformer()
        areas.enumerated().forEach {
            let areaCell = areaMatrix.cell(atRow: 0, column: $0.offset)
            areaCell?.title = t.transformedValue($0.element) as? String ?? String($0.element)
            areaCell?.tag = $0.element
        }
        
        areaId = areas.first ?? 0
    }
    
    private func updatePlaneSegment() {
        guard let content = airBaseController.content as? NSArray else { return }
        let area = NSCountedSet()
        content.forEach {
            if let i = ($0 as? KCAirBase)?.area_id {
                area.add(i)
            }
        }
        let count = area.count(for: areaId)
        [0, 1, 2].forEach { squadronTab.setEnabled($0 < count, forSegment: $0) }
    }
    
    private func updatePredicate() {
        airBaseController.filterPredicate = NSPredicate(format: "area_id = %ld AND rid = %ld", areaId, rId)
        airBaseController.setSelectionIndex(0)
        planesTable.deselectAll(nil)
    }
}

extension AirBaseWindowController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return tableView.make(withIdentifier: (tableColumn?.identifier)!, owner: nil)
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
}
