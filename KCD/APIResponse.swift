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

fileprivate func splitJSON(_ data: Data) -> String? {
    let prefix = "svdata="
    guard let string = data.utf8String,
        let range = string.range(of: prefix)
        else {
            print("data is wrong")
            return nil
    }
    return string[range.upperBound..<string.endIndex]
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
        .reduce([String: String]()) { $0.apended($1) }
}

struct APIResponse {
    let api: String
    let parameter: [String: String]
    let json: JSON
    let date: Date
    var success: Bool {
        if let r = json["api_result"].int { return r == 1 }
        return false
    }
    
    init?(request: URLRequest, data: Data) {
        date = Date()
        
        guard let josn = splitJSON(data)
            else {
                print("Can not parse JSON")
                return nil
        }
        self.json = JSON(parseJSON: josn)
        
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
    }
}
