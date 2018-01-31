//
//  ResourceViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/25.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class ResourceViewController: NSViewController {
    
    @objc override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        
        switch key {
            
        case #keyPath(shipNumberColor): return [#keyPath(maxChara), #keyPath(shipCount), #keyPath(minimumColoredShipCount)]
            
        default: return []
        }
    }
    
    @objc let managedObjectContext = ServerDataStore.default.context
    
    deinit {
        
        unbind(NSBindingName(#keyPath(maxChara)))
        unbind(NSBindingName(#keyPath(shipCount)))
    }
    
    @IBOutlet private var shipController: NSArrayController!
    @IBOutlet private var basicController: NSObjectController!
    
    @objc dynamic var maxChara: Int = 0
    @objc dynamic var shipCount: Int = 0
    @objc dynamic var shipNumberColor: NSColor {
        
        if shipCount > maxChara - minimumColoredShipCount {
            
            return .orange
        }
        
        return .controlTextColor
    }
    
    @objc dynamic var minimumColoredShipCount: Int {
        
        get { return UserDefaults.standard[.minimumColoredShipCount] }
        set { UserDefaults.standard[.minimumColoredShipCount] = newValue }
    }
    
    override var nibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        bind(NSBindingName(#keyPath(maxChara)), to: basicController, withKeyPath: "selection.max_chara", options: nil)
        bind(NSBindingName(#keyPath(shipCount)), to: shipController, withKeyPath: "arrangedObjects.@count", options: nil)
    }
}
