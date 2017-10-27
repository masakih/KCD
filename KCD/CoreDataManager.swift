//
//  CoreDataManager.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/10/26.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

enum CoreDataManagerType {
    
    case reader
    case editor
}

enum CoreDataError: Error {
    
    case applicationDirectoryIsFile
    case couldNotCreateModel
    case couldNotCreateCoordinator(String)
}

protocol CoreDataProvider {
    
    init(type: CoreDataManagerType)
    
    static var core: CoreDataCore { get }
    
    var context: NSManagedObjectContext { get }
    
    func save()
    func removeDataFile()
}

protocol CoreDataAccessor: CoreDataProvider {
    
    func insertNewObject<T>(for entity: Entity<T>) -> T?
    func delete(_ object: NSManagedObject)
    func object<T>(of entity: Entity<T>, with objectId: NSManagedObjectID) -> T?
    func objects<T>(of entity: Entity<T>, sortDescriptors: [NSSortDescriptor]?, predicate: NSPredicate?) throws -> [T]
    
    func object(with objectId: NSManagedObjectID) -> NSManagedObject
}

protocol CoreDataManager: CoreDataAccessor {
    
    associatedtype InstanceType = Self
    
    static var `default`: InstanceType { get }
    
    static func oneTimeEditor() -> InstanceType
}

// MARK: - Extension
extension CoreDataProvider {
    
    func save() {
        
        if !context.commitEditing() {
            
            print("\(String(describing: type(of: self))) unable to commit editing before saveing")
            
            return
        }
        
        do {
            
            try context.save()
            
        } catch {
            
            presentOnMainThread(error)
        }
        
        if let p = context.parent {
            
            p.performAndWait {
                do {
                    
                    try p.save()
                    
                } catch {
                    
                    self.presentOnMainThread(error)
                }
            }
        }
    }
    
    func removeDataFile() {
        
        removeAllDataFile(named: type(of: self).core.config.fileName)
    }
    
    private func presentOnMainThread(_ error: Error) {
        
        if Thread.isMainThread {
            
            NSApp.presentError(error)
            
        } else {
            
            DispatchQueue.main.sync {
                
                _ = NSApp.presentError(error)
            }
        }
    }
    
    static func context(for type: CoreDataManagerType) -> NSManagedObjectContext {
        
        switch type {
        case .reader: return core.parentContext
            
        case .editor: return core.editorContext()
        }
    }
}

extension CoreDataAccessor {
    
    func insertNewObject<T>(for entity: Entity<T>) -> T? {
        
        return NSEntityDescription.insertNewObject(forEntityName: entity.name, into: context) as? T
    }
    
    func delete(_ object: NSManagedObject) {
        
        context.delete(object)
    }
    
    func object<T>(of entity: Entity<T>, with objectId: NSManagedObjectID) -> T? {
        
        return context.object(with: objectId) as? T
    }
    
    func objects<T>(of entity: Entity<T>, sortDescriptors: [NSSortDescriptor]? = nil, predicate: NSPredicate? = nil) throws -> [T] {
        
        let req = NSFetchRequest<T>(entityName: entity.name)
        req.sortDescriptors = sortDescriptors
        req.predicate = predicate
        
        return try context.fetch(req)
    }
    
    func object(with objectId: NSManagedObjectID) -> NSManagedObject {
        
        return context.object(with: objectId)
    }
}
