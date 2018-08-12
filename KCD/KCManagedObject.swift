//
//  KCManagedObject.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation
import CoreData
import Doutaku

enum KCManagedObjectError: Error {
    
    case invalid
}

class KCManagedObject: NSManagedObject {
    
    private static let intValueKyes: Set<String> = ["api_aftershipid", "api_level"]
    
    override func validateValue(_ value: AutoreleasingUnsafeMutablePointer<AnyObject?>, forKey key: String) throws {
        
        if value.pointee is NSNull {
            
            value.pointee = nil
            
            return
        }
        
        if KCManagedObject.intValueKyes.contains(key) {
            
            if let _ = value.pointee as? Int {
                
                return
            }
            if let s = value.pointee as? String {
                
                value.pointee = Int(s) as AnyObject?
                
                return
            }
            
            print("KCManagedObject type \(type(of: value.pointee))")
            
            throw KCManagedObjectError.invalid
        }
    }
    
    override func value(forUndefinedKey key: String) -> Any? {
        
        if key == "description" {
            
            return value(forKey: "description_")
        }
        
        if key.hasPrefix("api_") {
            
            let k = String(key[key.index(key.startIndex, offsetBy: 4)...])
            
            return value(forKey: k)
        }
        
        print("Entity \(String(describing: self)) dose not have key \(key)")
        
        return nil
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
        if key == "description" {
            
            setValue(value, forKey: "description_")
            
            return
        }
        
        if key.hasPrefix("api_") {
            
            let k = String(key[key.index(key.startIndex, offsetBy: 4)...])
            setValue(value, forKey: k)
            
            return
        }
        
        print("Entity \(String(describing: self)) dose not have key \(key)")
    }
}
