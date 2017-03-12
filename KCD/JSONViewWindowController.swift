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
    var commands: NSMutableArray = []
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        bind("arguments", to: apis, withKeyPath: "selection.argument")
        bind("json", to: apis, withKeyPath: "selection.json")
    }
    
    func setCommand(_ command: NSDictionary) {
        willChangeValue(forKey: "commands")
        commands.add(command)
        didChangeValue(forKey: "commands")
    }
    func setCommandArray(_ commands: NSArray) {
        willChangeValue(forKey: "commands")
        self.commands.addObjects(from: commands as! [Any])
        didChangeValue(forKey: "commands")
    }
    
    @IBAction func clearLog(_ sender: AnyObject?) {
        willChangeValue(forKey: "commands")
        commands.removeAllObjects()
        didChangeValue(forKey: "commands")
    }
}
