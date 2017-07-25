//
//  ResourceViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/25.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class ResourceViewController: NSViewController {
    
    class func keyPathsForValuesAffectingShipNumberColor() -> Set<String> {
        
        return [#keyPath(maxChara), #keyPath(shipCount), #keyPath(minimumColoredShipCount)]
    }
    
    let managedObjectContext = ServerDataStore.default.context
    
    deinit {
        
        unbind(#keyPath(maxChara))
        unbind(#keyPath(shipCount))
    }
    
    @IBOutlet var shipController: NSArrayController!
    @IBOutlet var basicController: NSObjectController!
    
    dynamic var maxChara: Int = 0
    dynamic var shipCount: Int = 0
    dynamic var shipNumberColor: NSColor {
        
        if shipCount > maxChara - minimumColoredShipCount {
            
            return NSColor.orange
            
        }
        
        return NSColor.controlTextColor
    }
    
    dynamic var minimumColoredShipCount: Int {
        
        get { return UserDefaults.standard.minimumColoredShipCount }
        set { UserDefaults.standard.minimumColoredShipCount = newValue }
    }
    
    override var nibName: String! {
        
        return "ResourceViewController"
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        bind(#keyPath(maxChara), to: basicController, withKeyPath: "selection.max_chara", options: nil)
        bind(#keyPath(shipCount), to: shipController, withKeyPath: "arrangedObjects.@count", options: nil)
    }
}
