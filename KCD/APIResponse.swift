//
//  APIResponse.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/20.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import SwiftyJSON

extension JSON {
    
    func value(for keyPath: String) -> JSON {
        
        return self[keyPath.components(separatedBy: ".")]
    }
    
    var last: JSON {
        
        let index = self.count - 1
        
        return self[index]
    }
}

private func splitJSON(_ data: Data) -> String? {
    
    let prefix = "svdata="
    
    guard let string = data.utf8String,
        let range = string.range(of: prefix) else {
            
            Logger.shared.log("data is wrong")
            
            return nil
    }
    
    return String(string[range.upperBound...])
}

struct APIResponse {
    
    let api: API
    let parameter: Parameter
    let json: JSON
    let date: Date
    
    var success: Bool {
        
        if let r = json["api_result"].int { return r == 1 }
        
        return false
    }
    
    init(api: API, parameter: Parameter, json: JSON) {
        
        self.api = api
        self.parameter = parameter
        self.json = json
        self.date = Date()
    }
    
    init?(request: URLRequest, data: Data) {
        
        date = Date()
        
        guard let josn = splitJSON(data) else {
            
            Logger.shared.log("Can not parse JSON")
            
            return nil
        }
        
        self.json = JSON(parseJSON: josn)
        
        guard let parameter = Parameter(request) else {
            
            Logger.shared.log("Can not parse Parameter")
            
            return nil
        }
        
        self.parameter = parameter
        
        guard let api = request.url?.path else {
            
            Logger.shared.log("URLRequest is wrong")
            
            return nil
        }
        
        self.api = API(endpointPath: api)
    }
}
