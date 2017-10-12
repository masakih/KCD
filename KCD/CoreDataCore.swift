//
//  CoreDataManager.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

// MARK: enum
enum CoreDataManagerType {
    
    case reader
    case editor
}

// MARK: - struct
struct CoreDataConfiguration {
    
    let modelName: String
    let fileName: String
    let options: [AnyHashable: Any]
    let type: String
    let tryRemake: Bool
    
    private static let defaultOptions: [AnyHashable: Any] = [
        NSMigratePersistentStoresAutomaticallyOption: true,
        NSInferMappingModelAutomaticallyOption: true
    ]
    
    init(_ modelName: String,
         fileName: String? = nil,
         options: [AnyHashable: Any] = defaultOptions,
         type: String = NSSQLiteStoreType,
         tryRemake: Bool = false) {
        
        self.modelName = modelName
        self.fileName = fileName ?? "\(modelName).storedata"
        self.options = options
        self.type = type
        self.tryRemake = tryRemake
    }
}

struct CoreDataCore {
    
    let config: CoreDataConfiguration
    let parentContext: NSManagedObjectContext
    private let model: NSManagedObjectModel
    private let coordinator: NSPersistentStoreCoordinator
    
    init(_ config: CoreDataConfiguration) {
        
        self.config = config
        
        do {
            
            (model, coordinator, parentContext) = try genarate(config)
            
        } catch {
            
            NSApplication.shared.presentError(error)
            fatalError("CoreDataCore: can not initialize. \(error)")
        }
    }
    
    func editorContext() -> NSManagedObjectContext {
        
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.parent = parentContext
        moc.undoManager = nil
        
        return moc
    }
}

// MARK: - protocol
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
        
        remove(name: type(of: self).core.config.fileName)
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
