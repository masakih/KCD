//
//  CoreDataManager.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/05.
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

struct CoreDataIntormation {
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
    let info: CoreDataIntormation
    let model: NSManagedObjectModel
    let coordinator: NSPersistentStoreCoordinator
    let parentContext: NSManagedObjectContext
    
    init(_ info: CoreDataIntormation) {
        self.info = info
        do {
            let genaratee = try MocGenerater.genarate(info)
            (self.model, self.coordinator, self.parentContext) = genaratee
        } catch {
            NSApplication.shared().presentError(error)
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


protocol CoreDataProvider {
    init(type: CoreDataManagerType)
    var core: CoreDataCore { get }
    var context: NSManagedObjectContext { get }
    func save()
}

protocol CoreDataManager {
    associatedtype InstanceType = Self
    
    static var `default`: InstanceType { get }
    static func oneTimeEditor() -> InstanceType
    
    func removeDataFile()
}

protocol CoreDataAccessor: CoreDataProvider {
    func insertNewObject<T>(for entity: Entity<T>) -> T?
    func delete(_ object: NSManagedObject)
    func object(with objectId: NSManagedObjectID) -> NSManagedObject
    func objects<T>(with entity: Entity<T>, sortDescriptors: [NSSortDescriptor]?, predicate: NSPredicate?) throws -> [T]
}

private class CoreDataRemover {
    class func remove(name: String) {
        ["", "-wal", "-shm"]
            .map { name + $0 }
            .map { ApplicationDirecrories.support.appendingPathComponent($0) }
            .forEach { removeDataFile(at: $0) }
    }
    private class func removeDataFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Could not remove file for URL (\(url))")
        }
    }
}

private class MocGenerater {
    class func genarate(_ info: CoreDataIntormation) throws ->
        (model: NSManagedObjectModel, coordinator: NSPersistentStoreCoordinator, moc: NSManagedObjectContext) {
            do {
                let model = try createModel(info)
                let coordinator = try getCoordinator(info, model)
                let moc = createContext(coordinator)
                return (model: model, coordinator: coordinator, moc: moc)
            } catch {
                throw error
            }
    }
    
    private class func createModel(_ info: CoreDataIntormation) throws -> NSManagedObjectModel {
        let modelURL = Bundle.main.url(forResource: info.modelName, withExtension: "momd")!
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw CoreDataError.couldNotCreateModel
        }
        return model
    }
    private class func getCoordinator(_ info: CoreDataIntormation,
                                      _ model: NSManagedObjectModel) throws -> NSPersistentStoreCoordinator {
        do {
            return try createCoordinator(info, model)
        } catch {
            let nserror = error as NSError
            // Data Modelが更新されていたらストアファイルを削除してもう一度
            if nserror.domain == NSCocoaErrorDomain,
                (nserror.code == 134130 || nserror.code == 134110),
                info.tryRemake {
                self.removeDataFile(info)
                do {
                    return try createCoordinator(info, model)
                } catch {
                    print("Fail crrate NSPersistentStoreCoordinator twice.")
                }
            }
            throw error
        }
    }
    private class func createCoordinator(_ info: CoreDataIntormation,
                                         _ model: NSManagedObjectModel) throws -> NSPersistentStoreCoordinator {
        if !checkDirectory(ApplicationDirecrories.support) {
            let failureReason = "Can not use directory \(ApplicationDirecrories.support.path)"
            throw CoreDataError.couldNotCreateCoordinator(failureReason)
        }
        
        let coordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let url = ApplicationDirecrories.support.appendingPathComponent(info.fileName)
        do {
            try coordinator.addPersistentStore(ofType: info.type,
                                               configurationName: nil,
                                               at: url,
                                               options: info.options)
        } catch {
            throw error
        }
        return coordinator
    }
    private class func createContext(_ coordinator: NSPersistentStoreCoordinator) -> NSManagedObjectContext {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = coordinator
        moc.undoManager = nil
        return moc
    }
    private class func removeDataFile(_ info: CoreDataIntormation) {
        CoreDataRemover.remove(name: info.fileName)
    }
}

extension CoreDataManager where Self: CoreDataProvider {
    func removeDataFile() {
        CoreDataRemover.remove(name: self.core.info.fileName)
    }
}

extension CoreDataProvider {
    func save() {
        if !context.commitEditing() {
            print("\(String(describing: type(of: self))) unable to commit editing before saveing")
            return
        }
        do {
            try context.save()
        } catch { presentOnMainThread(error) }
        if let p = context.parent {
            p.performAndWait {
                do {
                    try p.save()
                } catch { self.presentOnMainThread(error) }
            }
        }
    }
    private func presentOnMainThread(_ error: Error) {
        if Thread.isMainThread {
            NSApp.presentError(error)
        } else {
            DispatchQueue.main.sync {
                let _ = NSApp.presentError(error)
            }
        }
    }
}

extension CoreDataAccessor {
    func insertNewObject<T>(for entity: Entity<T>) -> T? {
        return NSEntityDescription
            .insertNewObject(forEntityName: entity.name,
                             into: context) as? T
    }
    func delete(_ object: NSManagedObject) {
        context.delete(object)
    }
    func object(with objectId: NSManagedObjectID) -> NSManagedObject {
        return context.object(with: objectId)
    }
    func objects<T>(with entity: Entity<T>,
                    sortDescriptors: [NSSortDescriptor]? = nil,
                    predicate: NSPredicate? = nil) throws -> [T] {
        let req = NSFetchRequest<T>(entityName: entity.name)
        req.sortDescriptors = sortDescriptors
        req.predicate = predicate
        return try context.fetch(req)
    }
}
