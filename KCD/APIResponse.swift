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

private extension Data {
    
    var utf8String: String? { return String(data: self, encoding: .utf8) }
}

func +<Key, Value> (lhs: [Key: Value], rhs: (Key, Value)) -> [Key: Value] {
    
    var new = lhs
    new[rhs.0] = rhs.1
    
    return new
}

private func splitJSON(_ data: Data) -> String? {
    
    let prefix = "svdata="
    
    guard let string = data.utf8String,
        let range = string.range(of: prefix) else {
            
            print("data is wrong")
            return nil
    }
    
    return String(string[range.upperBound...])
}

private func parseParameter(_ request: URLRequest) -> [String: String]? {
    
    return request
        .httpBody?
        .utf8String?
        .removingPercentEncoding?
        .components(separatedBy: "&")
        .map { $0.components(separatedBy: "=") }
        .filter { $0.count == 2 }
        .map { (piar: [String]) -> (String, String) in (piar[0], piar[1]) }
        .reduce(into: [String: String]()) { (dict: inout [String: String], value: (String, String)) in
            
            dict[value.0] = value.1
    }
}

struct ParameterValue {
    
    private let rawValue: String?
    
    var int: Int? { return rawValue.flatMap { Int($0) } }
    var double: Double? { return rawValue.flatMap { Double($0) } }
    var string: String? { return rawValue }
    var bool: Bool? {
        
        guard let _ = rawValue else { return nil }
        
        if let i = self.int {
            
            return i != 0
        }
        
        if let s = self.string?.lowercased() {
            
            switch s {
            case "true", "yes", "t", "y": return true
                
            default: return false
            }
        }
        
        return false
    }
    
    var valid: Bool { return rawValue != nil }
    
    init(_ rawValue: String?) {
        
        self.rawValue = rawValue
    }
}

struct Parameter {
    
    private let rawValue: [String: String]
    
    init(_ rawValue: [String: String]) {
        
        self.rawValue = rawValue
    }
    
    init?(_ request: URLRequest) {
        
        guard let paramList = parseParameter(request) else { return nil }
        
        self.init(paramList)
    }
    
    subscript(_ key: String) -> ParameterValue {
        
        return ParameterValue(rawValue[key])
    }
    
    func map<T>(_ transform: (String, String) throws -> T) rethrows -> [T] {
        
        return try rawValue.map(transform)
    }
}

struct APIResponse {
    
    let api: String
    let parameter: Parameter
    let json: JSON
    let date: Date
    var success: Bool {
        
        if let r = json["api_result"].int { return r == 1 }
        
        return false
    }
    
    init(api: String, parameter: Parameter, json: JSON) {
        
        self.api = api
        self.parameter = parameter
        self.json = json
        self.date = Date()
    }
    
    init?(request: URLRequest, data: Data) {
        
        date = Date()
        
        guard let josn = splitJSON(data) else {
            
            print("Can not parse JSON")
            return nil
        }
        
        self.json = JSON(parseJSON: josn)
        
        guard let parameter = Parameter(request) else {
            
            print("Can not parse Parameter")
            return nil
        }
        
        self.parameter = parameter
        
        guard let api = request.url?.path else {
            
            print("URLRequest is wrong")
            return nil
        }
        
        self.api = api
    }
}
