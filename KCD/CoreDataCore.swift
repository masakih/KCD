//
//  CoreDataManager.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

struct CoreDataConfiguration {
    
    let modelName: String
    let fileName: String
    let options: [AnyHashable: Any]
    let type: String
    
    // try remake data file, if model file modified.
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
            
            let generator = MOCGenerator(config)
            (model, coordinator, parentContext) = try generator.genarate()
            
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
