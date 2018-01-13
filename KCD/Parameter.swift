//
//  Parameter.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/12/12.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

private func parseParameter(_ request: URLRequest) -> [String: String]? {
    
    return request
        .httpBody?
        .utf8String?
        .removingPercentEncoding?
        .components(separatedBy: "&")
        .map { $0.components(separatedBy: "=") }
        .filter { $0.count == 2 }
        .reduce(into: [String: String]()) { (dict: inout [String: String], value: [String]) in
            
            dict[value[0]] = value[1]
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
    var array: [ParameterValue] {
        
        return rawValue?.components(separatedBy: ",").map { ParameterValue($0) } ?? []
    }
    var integerArray: [Int] {
        
        return array.flatMap { $0.int }
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

extension Parameter: Equatable {
    
    public static func == (lhs: Parameter, rhs: Parameter) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
