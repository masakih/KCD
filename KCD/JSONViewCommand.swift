//
//  JSONViewCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/19.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

#if ENABLE_JSON_LOG

class JSONViewCommand: JSONCommand {
    let jsonTree: [JSONNode]?
    let parameterList: [Any]
    let recieveDate: Date?
    let command: JSONCommand
    
    init(apiResponse: APIResponse, command: JSONCommand) {
        self.recieveDate = Date()
        self.parameterList = apiResponse.argumentArray
        self.jsonTree = JSONNode
            .nodeWithJSON(apiResponse.json as AnyObject?)
            .map { [$0] }
        self.command = command
        super.init(apiResponse: apiResponse)
    }
    
    required init(apiResponse: APIResponse) {
        fatalError("use init(apiResponse:command:)")
    }
    
    override func execute() {
        command.execute()
        
        guard let _ = jsonTree else { return print("jsonTree is nil.") }
        guard let _ = recieveDate else { return print("recieveDate is nil.") }
        
        DispatchQueue.main.async {
            guard let appDelegate = NSApplication.shared().delegate as? AppDelegate
                else { return print("Can not get AppDelegate") }
            let commands: [String:Any] = [
                "api": self.api,
                "argument": self.parameterList,
                "json": self.jsonTree ?? [],
                "recieveDate": self.recieveDate ?? Date(),
                "date": Date()
             ]
            appDelegate.jsonViewWindowController?.setCommand(commands as NSDictionary)
        }
    }
}

#endif
