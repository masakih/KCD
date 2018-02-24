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
    
    case saveLocationIsUnuseable
    case couldNotCreateModel
    case couldNotCreateCoordinator(String)
    case couldNotSave(String)
}

protocol CoreDataProvider {
    
    init(type: CoreDataManagerType)
    
    static var core: CoreDataCore { get }
    
    var context: NSManagedObjectContext { get }
    
    func save(errorHandler: (Error) -> Void)
    func save() throws
}

protocol CoreDataAccessor: CoreDataProvider {
    
    func sync(execute: () -> Void)
    func sync<T>(execute: () -> T) -> T
    func async(execute: @escaping () -> Void)
    
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
    
    static func context(for type: CoreDataManagerType) -> NSManagedObjectContext {
        
        switch type {
        case .reader: return core.parentContext
            
        case .editor: return core.editorContext()
        }
    }
    
    func save(errorHandler: (Error) -> Void) {
        
        do {
            
            try save()
            
        } catch {
            
            errorHandler(error)
        }
    }
    
    func save() throws {
        
        var caughtError: Error?
        context.performAndWait {
            
            guard context.commitEditing() else {
                
                caughtError = CoreDataError.couldNotSave("\(String(describing: type(of: self))) unable to commit editing before saveing")
                return
            }
            
            do {
                
                try context.save()
                
            } catch let error as NSError {
                
                caughtError = CoreDataError.couldNotSave(error.localizedDescription)
                return
            }
            
            guard let parent = context.parent else { return }
            
            // save parent context
            var catchedError: NSError? = nil
            parent.performAndWait {
                
                do {
                    
                    try parent.save()
                    
                } catch let error as NSError {
                    
                    catchedError = error
                }
            }
            
            if let error = catchedError {
                
                caughtError = CoreDataError.couldNotSave(error.localizedDescription)
            }
        }
        
        if let error = caughtError {
            
            throw error
        }
    }
    
    func presentOnMainThread(_ error: Error) {
        
        if Thread.isMainThread {
            
            NSApp.presentError(error)
            
        } else {
            
            DispatchQueue.main.sync {
                
                _ = NSApp.presentError(error)
            }
        }
    }
}

extension CoreDataAccessor {
    
    func sync(execute work: () -> Void) {
        
        self.context.performAndWait(work)
    }
    
    func sync<T>(execute work: () -> T) -> T {
        
        var value: T!
        sync {
            value = work()
        }
        return value
    }
    
    func async(execute work: @escaping () -> Void) {
        
        self.context.perform(work)
    }
    
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
        
        var result: [T]?
        var caughtError: Error?
        sync {
            do {
                
                result = try self.context.fetch(req)
            } catch {
                
                caughtError = error
            }
        }
        if let error = caughtError {
            
            throw error
        }
        
        return result ?? []
    }
    
    func object(with objectId: NSManagedObjectID) -> NSManagedObject {
        
        var result: NSManagedObject?
        sync {
            result = self.context.object(with: objectId)
        }
        return result!
    }
}
