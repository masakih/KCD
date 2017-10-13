//
//  Entity.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import CoreData

struct Entity<T: NSManagedObject> {
    
    let name: String
}

protocol EntityProvider {
    
    associatedtype ObjectType: NSManagedObject = Self
    
    static var entityName: String { get }
    static var entity: Entity<ObjectType> { get }
}

extension EntityProvider {
    
    static var entity: Entity<ObjectType> {
        
        return Entity<ObjectType>(name: entityName)
    }
}

// MARK: - Implementations
extension NSManagedObject {
    
    class var entityName: String { return String(describing: self) }
}
