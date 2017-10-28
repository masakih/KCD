//
//  JSONViewCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/19.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

#if ENABLE_JSON_LOG

final class JSONViewCommand: JSONCommand {
    
    let jsonTree: [JSONNode]?
    let parameterList: [Any]
    let recieveDate: Date?
    let command: JSONCommand
    
    init(apiResponse: APIResponse, command: JSONCommand) {
        
        self.recieveDate = Date()
        self.parameterList = apiResponse
            .parameter
           .map { ["key": $0, "value": $1] }
        self.jsonTree = JSONNode
            .nodeWithJSON(apiResponse.json)
            .map { [$0] }
        self.command = command
        
        super.init(apiResponse: apiResponse)
    }
    
    required init(apiResponse: APIResponse) {
        
        fatalError("use init(apiResponse:command:)")
    }
    
    override func execute() {
        
        do {
            
            try command.execute()
            
        } catch {
            
            print("JSONTracker Cought Exception -> \(error)")
        }
        
        guard let _ = jsonTree else { return Logger.shared.log("jsonTree is nil.") }
        guard let _ = recieveDate else { return Logger.shared.log("recieveDate is nil.") }
        
        DispatchQueue.main.async {
            
            let commands: [String: Any] = [
                "api": self.api,
                "argument": self.parameterList,
                "json": self.jsonTree ?? [],
                "recieveDate": self.recieveDate ?? Date(),
                "date": Date()
             ]
            AppDelegate.shared.jsonViewWindowController?.setCommand(commands)
        }
    }
}

#endif
