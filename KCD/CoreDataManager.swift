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
        
        guard context.commitEditing() else {
            
            throw CoreDataError.couldNotSave("\(String(describing: type(of: self))) unable to commit editing before saveing")
        }
        
        do {
            
            try context.save()
            
        } catch (let error as NSError) {
            
            throw CoreDataError.couldNotSave(error.localizedDescription)
        }
        
        guard let parent = context.parent else { return }
        
        // save parent context
        var catchedError: NSError? = nil
        parent.performAndWait {
            
            do {
                
                try parent.save()
                
            } catch (let error as NSError) {
                
                catchedError = error
            }
        }
        
        if let error = catchedError {
            
            throw CoreDataError.couldNotSave(error.localizedDescription)
            
        }
    }
    
    func removeDataFile() {
        
        MOCGenerator.removeDataFile(type(of: self).core.config)
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
