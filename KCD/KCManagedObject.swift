//
//  KCManagedObject.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation
import CoreData

enum KCManagedObjectError: Error {
    
    case invalid
}

class KCManagedObject: NSManagedObject {
    
    private static let intValueKyes =
        [
    "api_enqflg", "api_aftershipid", "api_progress", "api_usebull",
    "api_flagship", "api_name_id",
    "api_comment_id", "api_nickname_id", "api_member_id",
    "api_flag_0", "api_flag_1", "api_flag_2", "api_flag_3", "api_flag_4",
    "api_flag_5", "api_flag_6", "api_flag_7",
    "api_level"
    ]
    
    override func validateValue(_ value: AutoreleasingUnsafeMutablePointer<AnyObject?>, forKey key: String) throws {
        
        if value.pointee is NSNull {
            
            value.pointee = nil
            
            return
        }
        
        if KCManagedObject.intValueKyes.contains(key) {
            
            if let _ = value.pointee as? Int { return }
            if let s = value.pointee as? String {
                
                value.pointee = Int(s) as AnyObject?
                
                return
            }
            
            print("KCManagedObject type \(type(of: value.pointee))")
            
            throw KCManagedObjectError.invalid
        }
    }
    
    override func value(forUndefinedKey key: String) -> Any? {
        
        if key == "description" { return value(forKey: "description_") }
        
        if key.hasPrefix("api_") {
            
/* MARK: CONVERT */            let k = String(key[key.index(key.startIndex, offsetBy: 4)...])
            
            return value(forKey: k)
        }
        
        print("Entity \(type(of: self).entityName) dose not have key \(key)")
        
        return nil
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
        if key == "description" {
            
            setValue(value, forKey: "description_")
            
            return
        }
        
        if key.hasPrefix("api_") {
            
/* MARK: CONVERT */            let k = String(key[key.index(key.startIndex, offsetBy: 4)...])
            setValue(value, forKey: k)
            
            return
        }
        
        print("Entity \(type(of: self).entityName) dose not have key \(key)")
    }
}
