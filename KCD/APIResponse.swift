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

func +<Key, Value> (lhs: [Key: Value], rhs: (Key, Value)) -> [Key: Value] {
    var new = lhs
    new[rhs.0] = rhs.1
    return new
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
        .reduce([String: String]()) { $0 + $1 }
}

struct ParameterValue {
    private let rowValue: String?
    
    var int: Int? { return rowValue.flatMap { Int($0) } }
    var double: Double? { return rowValue.flatMap { Double($0) } }
    var string: String? { return rowValue }
    var bool: Bool? {
        guard let _ = rowValue else { return nil }
        if let i = self.int {
            return i != 0
        }
        if let s = self.string?.lowercased() {
            switch s {
            case "true", "yes": return true
            default: return false
            }
        }
        return false
    }
    var valid: Bool { return rowValue != nil }
    
    init(_ rowValue: String?) {
        self.rowValue = rowValue
    }
}

struct Parameter {
    private let rowValue: [String: String]
    
    init(_ rowValue: [String: String]) {
        self.rowValue = rowValue
    }
    init?(_ request: URLRequest) {
        guard let paramList = parseParameter(request)
            else { return nil }
        self.init(paramList)
    }
    
    subscript(_ key: String) -> ParameterValue {
        return ParameterValue(rowValue[key])
    }
    func map<T>(_ transform: (String, String) throws -> T) rethrows -> [T] {
        return try rowValue.map(transform)
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
    
    init?(request: URLRequest, data: Data) {
        date = Date()
        
        guard let josn = splitJSON(data)
            else {
                print("Can not parse JSON")
                return nil
        }
        self.json = JSON(parseJSON: josn)
        
        guard let parameter = Parameter(request)
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
