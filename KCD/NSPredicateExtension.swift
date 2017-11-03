//
//  NSPredicateExtension.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/10/07.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

public extension NSPredicate {
    
    private convenience init(expression property: String, _ operation: String, _ value: Any) {
        
        self.init(format: "%K \(operation) %@", argumentArray: [property, value])
    }
    
}

public extension NSPredicate {
    
    public convenience init(_ property: String, equal value: Any) {
        
        self.init(expression: property, "=", value)
    }
    
    public convenience init(_ property: String, notEqual value: Any) {
        
        self.init(expression: property, "!=", value)
    }
    
    public convenience init(_ property: String, equalOrGreaterThan value: Any) {
        
        self.init(expression: property, ">=", value)
    }
    
    public convenience init(_ property: String, equalOrLessThan value: Any) {
        
        self.init(expression: property, "<=", value)
    }
    
    public convenience init(_ property: String, greaterThan value: Any) {
        
        self.init(expression: property, ">", value)
    }
    
    public convenience init(_ property: String, lessThan value: Any) {
        
        self.init(expression: property, "<", value)
    }
    
    public convenience init(_ property: String, valuesIn values: [Any]) {
        
        self.init(format: "%K IN %@", argumentArray: [property, values])
    }
    
}

public extension NSPredicate {
    
    public func compound(predicates: [NSPredicate], type: NSCompoundPredicate.LogicalType = .and) -> NSPredicate {
        
        let p = [self] + predicates
        
        switch type {
        case .and: return NSCompoundPredicate(andPredicateWithSubpredicates: p)
        case .or:  return NSCompoundPredicate(orPredicateWithSubpredicates: p)
        case .not: return NSCompoundPredicate(notPredicateWithSubpredicate: self.compound(predicates: p))
        }
    }
}

public extension NSPredicate {
    
    public static func not(_ predicate: NSPredicate) -> NSPredicate {
        
        return NSCompoundPredicate(notPredicateWithSubpredicate: predicate)
    }
    
    public static func and(_ predicates: [NSPredicate]) -> NSPredicate {
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    public static func or(_ predicates: [NSPredicate]) -> NSPredicate {
        
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }
    
    public static func `true`(_ property: String) -> NSPredicate {
        
        return NSPredicate(format: "%K = TRUE", property)
    }
    
    public static func `false`(_ property: String) -> NSPredicate {
        
        return NSPredicate(format: "%K != TRUE", property)
    }
    
    public static func isNil(_ property: String) -> NSPredicate {
        
        return NSPredicate(format: "%K = NULL", property)
    }
    
    public static func isNotNil(_ property: String) -> NSPredicate {
        
        return NSPredicate(format: "%K != NULL", property)
    }
    
    //
    public func and(_ predicate: NSPredicate) -> NSPredicate {
        
        return self.compound(predicates: [predicate], type: .and)
    }
    
    public func or(_ predicate: NSPredicate) -> NSPredicate {
        
        return self.compound(predicates: [predicate], type: .or)
    }
}

public extension NSPredicate {
    
    public static var empty: NSPredicate {
        
        return NSPredicate(value: true)
    }
}

//
//
//
//precedencegroup PredicateAddPrecedence {
//    associativity: right
//    higherThan: AssignmentPrecedence
//}
//precedencegroup PredicatePrecedence {
//    higherThan: PredicateAddPrecedence
//}
//
//infix operator |==| : PredicatePrecedence
//infix operator |!=| : PredicatePrecedence
//
//infix operator |<*| : PredicatePrecedence
//
//infix operator |+| : PredicateAddPrecedence
//infix operator ||| : PredicateAddPrecedence
//prefix operator |!|
//
//public extension NSPredicate {
//
//    static func |+| (lhs: NSPredicate, rhs: NSPredicate) -> NSPredicate {
//
//        return .and([lhs, rhs])
//    }
//
//    static func ||| (lhs: NSPredicate, rhs: NSPredicate) -> NSPredicate {
//
//        return .or([lhs, rhs])
//    }
//
//    static prefix func |!| (lhs: NSPredicate) -> NSPredicate {
//
//        return .not(lhs)
//    }
//}
//
//public struct PredicateKey {
//
//    let name: String
//
//    init(_ name: String) {
//
//        self.name = name
//    }
//
//    static func |==| (lhs: PredicateKey, rhs: Any) -> NSPredicate {
//
//        return NSPredicate(lhs.name, equal: rhs)
//    }
//
//    static func |!=| (lhs: PredicateKey, rhs: Any) -> NSPredicate {
//
//        return NSPredicate(lhs.name, notEqual: rhs)
//    }
//
//    static func |<*| (lhs: PredicateKey, rhs: [Any]) -> NSPredicate {
//
//        return NSPredicate(lhs.name, valuesIn: rhs)
//    }
//}
