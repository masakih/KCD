//
//  AirBaseWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/22.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class AirBaseWindowController: NSWindowController {
    
    @objc let managedObjectContext = ServerDataStore.default.context
    
    @IBOutlet private var areaMatrix: NSMatrix!
    @IBOutlet private var squadronTab: NSSegmentedControl!
    @IBOutlet private var planesTable: NSTableView!
    @IBOutlet private var airBaseController: NSArrayController!
    
    private var contentObservation: NSKeyValueObservation?
    
    override var windowNibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    @objc dynamic var areaId: Int = 0 {
        
        didSet {
            
            updatePredicate()
            updatePlaneSegment()
        }
    }
    
    @objc dynamic var rId: Int = 1 {
        
        didSet {
            
            updatePredicate()
            updatePlaneSegment()
        }
    }
    
    private var areas: [Int] {
        
        guard let content = airBaseController.content as? [AirBase] else {
            
            return []
        }
        
        return content
            .compactMap { $0.area_id }
            .unique()
            .sorted(by: <)
    }
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
                
        contentObservation = airBaseController.observe(\NSArrayController.content) { [weak self] _, _ in
            
            guard let `self` = self else {
                
                return
            }
            
            self.updateAreaRadio()
            self.updatePlaneSegment()
            
            if self.areaId == 0 {
                
                self.areaId = self.areas.first ?? 0
                self.updatePredicate()
            }
        }
    }
    
    private func updateAreaRadio() {
        
        //  更新の必要性チェック
        let areas = self.areas
        let currentTags = areaMatrix.cells.map { $0.tag }
        
        if currentTags == areas {
            
            return
        }
        
        // 最初の設定以外でareasが空の場合は処理をしない
        if areas.isEmpty, areaId != 0 {
            
            return
        }
        
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
    }
    
    private func updatePlaneSegment() {
        
        guard let content = airBaseController.content as? [AirBase] else {
            
            return
        }
        
        let area = NSCountedSet()
        content.forEach { area.add($0.area_id) }
        let count = area.count(for: areaId)
        (0...2).forEach { squadronTab.setEnabled($0 < count, forSegment: $0) }
    }
    
    private func updatePredicate() {
        
        airBaseController.filterPredicate = NSPredicate.empty
            .and(NSPredicate(#keyPath(AirBase.area_id), equal: areaId))
            .and(NSPredicate(#keyPath(AirBase.rid), equal: rId))
        airBaseController.setSelectionIndex(0)
        planesTable.deselectAll(nil)
    }
}

extension AirBaseWindowController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let identifier = tableColumn?.identifier else {
            
            return nil
        }
        
        return tableView.makeView(withIdentifier: identifier, owner: nil)
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        
        return false
    }
}
