//
//  JSONViewWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class JSONViewWindowController: NSWindowController {
    
    deinit {
        
        unbind(NSBindingName(#keyPath(arguments)))
        unbind(NSBindingName(#keyPath(json)))
    }
    
    @IBOutlet var argumentsView: NSTableView!
    @IBOutlet var jsonView: NSOutlineView!
    @IBOutlet var apis: NSArrayController!
    
    override var windowNibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    @objc var arguments: NSArray?
    @objc var json: AnyObject?
    @objc var commands: [[String: Any]] = []
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        bind(NSBindingName(#keyPath(arguments)), to: apis, withKeyPath: "selection.argument")
        bind(NSBindingName(#keyPath(json)), to: apis, withKeyPath: "selection.json")
    }
    
    func setCommand(_ command: [String: Any]) {
        
        notifyChangeValue(forKey: #keyPath(commands)) {
            
            commands += [command]
        }
    }
    
    @IBAction func clearLog(_ sender: AnyObject?) {
        
        notifyChangeValue(forKey: #keyPath(commands)) {
            
            commands = []
        }
    }
}
