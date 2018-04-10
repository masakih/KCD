//
//  Debug.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/12.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

final class Debug {
    
    enum Level: Int {
        
        case none
        
        case test
        
        case debug
        
        case full
        
        func higher(other: Level) -> Bool {
            
            return self.rawValue >= other.rawValue
        }
    }
    
    private struct Args: CustomStringConvertible, CustomDebugStringConvertible {
        
        let args: [Any]
        let separator: String
        
        var description: String {
            
            return args.map { "\($0)" }.joined(separator: separator)
        }
        
        var debugDescription: String {
            
            return args
                .map { ($0 as? CustomDebugStringConvertible)?.debugDescription ?? "\($0)" }
                .joined(separator: separator)
        }
    }
    
    class func print(_ items: Any..., separator: String = " ", terminator: String = "\n", level: Level = .debug) {
        
            excute(level: level) {
                
                Swift.print(Args(args: items, separator: separator), separator: separator, terminator: terminator)
            }
    }
    
    class func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n", level: Level = .debug) {
        
            excute(level: level) {
                
                Swift.debugPrint(Args(args: items, separator: separator), separator: separator, terminator: terminator)
            }
    }
    
    class func dump<T>(_ value: T, name: String? = nil, indent: Int = 0, maxDepth: Int = Int.max, maxItems: Int = Int.max) -> T {
        
        #if DEBUG
        
            return Swift.dump(value, name: name, indent: indent, maxDepth: maxDepth, maxItems: maxItems)
        
        #else
        
            return value
        
        #endif
    }
    
    class func excute(level: Level, f: () -> Void) {
        
        if UserDefaults.standard[.degugPrintLevel].higher(other: level) {
            
            f()
        }
    }
}
