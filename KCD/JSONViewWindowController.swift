//
//  JSONViewWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class JSONViewWindowController: NSWindowController {
    deinit {
        unbind("arguments")
        unbind("json")
    }
    
    @IBOutlet var argumentsView: NSTableView!
    @IBOutlet var jsonView: NSOutlineView!
    @IBOutlet var apis: NSArrayController!
    
    override var windowNibName: String! {
        return "JSONViewWindowController"
    }
    
    var arguments: NSArray?
    var json: AnyObject?
    var commands: [[String: Any]] = []
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        bind("arguments", to: apis, withKeyPath: "selection.argument")
        bind("json", to: apis, withKeyPath: "selection.json")
    }
    
    func setCommand(_ command: [String: Any]) {
        notifyChangeValue(forKey: "commands") {
            commands += [command]
        }
    }
    
    @IBAction func clearLog(_ sender: AnyObject?) {
        notifyChangeValue(forKey: "commands") {
            commands = []
        }
    }
}
