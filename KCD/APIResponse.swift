//
//  APIResponse.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/20.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate extension Data {
    var utf8String: String? { return String(data: self, encoding: .utf8) }
}
fileprivate extension Dictionary {
    func apended(_ keyValue: (Key, Value) ) -> Dictionary {
        var dict  = self
        dict[keyValue.0] = keyValue.1
        return dict
    }
}

fileprivate func splitJSON(_ data: Data) -> Data? {
    let prefix = "svdata="
    guard let string = data.utf8String,
        let range = string.range(of: prefix)
        else {
            print("data is wrong")
            return nil
    }
    return string[range.upperBound..<string.endIndex].data(using: .utf8)
}
fileprivate func parseJSON(_ data: Data?) -> [String: Any]? {
    guard let data = data,
        let j = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]),
        let json = j as? [String: Any]
        else { return nil }
    return json
}

fileprivate func parseParameter(_ request: URLRequest) -> [String: String]? {
    return request
        .httpBody?
        .utf8String?
        .removingPercentEncoding?
        .components(separatedBy: "&")
        .map { $0.components(separatedBy: "=") }
        .filter { $0.count == 2 }
        .map { ($0[0], $0[1]) }
        .reduce([String:String]()) { $0.apended($1) }
}

struct APIResponse {
    let api: String
    let parameter: [String: String]
    let json: [String: Any]
    let date: Date
    var success: Bool {
        if let r = json["api_result"] as? Int { return r == 1 }
        return false
    }
    
    #if ENABLE_JSON_LOG
    let argumentArray: [[String: String]]
    #endif
    
    init?(request: URLRequest, data: Data) {
        date = Date()
        
        guard let json = parseJSON(splitJSON(data))
            else {
                print("Can not parse JSON")
                return nil
        }
        self.json = json
        
        guard let parameter = parseParameter(request)
            else {
                print("Can not parse Parameter")
                return nil
        }
        self.parameter = parameter
        
        guard let api = request.url?.path
            else {
                print("URLRequest is wrong")
                return nil
        }
        self.api = api
        
        #if ENABLE_JSON_LOG
            argumentArray = parameter.map { (key, value) in
                ["key": key, "value": value]
            }
        #endif
    }
}
