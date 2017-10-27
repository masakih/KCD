//
//  ManagedObjectContextGenerator.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/21.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

func genarate(_ config: CoreDataConfiguration) throws -> (model: NSManagedObjectModel, coordinator: NSPersistentStoreCoordinator, moc: NSManagedObjectContext) {
    
    let model = try createModel(config)
    let coordinator = try getCoordinator(config, model)
    let moc = createContext(coordinator)
    
    return (model: model, coordinator: coordinator, moc: moc)
}

func removeAllDataFile(named name: String) {
    
    ["", "-wal", "-shm"]
        .map { name + $0 }
        .map(ApplicationDirecrories.support.appendingPathComponent)
        .forEach(removeDataFile)
}

private func removeDataFile(at url: URL) {
    
    do {
        
        try FileManager.default.removeItem(at: url)
        
    } catch {
        
        print("Could not remove file for URL (\(url))")
    }
}

// MARK: - NSManagedObjectContext and ...
private  func createModel(_ config: CoreDataConfiguration) throws -> NSManagedObjectModel {
    
    guard let modelURL = Bundle.main.url(forResource: config.modelName, withExtension: "momd"),
        let model = NSManagedObjectModel(contentsOf: modelURL) else {
            
            throw CoreDataError.couldNotCreateModel
    }
    
    return model
}

private func getCoordinator(_ config: CoreDataConfiguration, _ model: NSManagedObjectModel) throws -> NSPersistentStoreCoordinator {
    
    do {
        
        return try createCoordinator(config, model)
        
    } catch (let error as NSError) {
        
        // Data Modelが更新されていたらストアファイルを削除してもう一度
        if error.domain == NSCocoaErrorDomain,
            (error.code == 134130 || error.code == 134110),
            config.tryRemake {
            
            removeAllDataFile(named: config.fileName)
            
            do {
                
                return try createCoordinator(config, model)
                
            } catch {
                
                print("Fail to create NSPersistentStoreCoordinator twice.")
            }
        }
        
        throw error
    }
}

private func createCoordinator(_ config: CoreDataConfiguration, _ model: NSManagedObjectModel) throws -> NSPersistentStoreCoordinator {
    
    if !checkDirectory(ApplicationDirecrories.support) {
        
        let failureReason = "Can not use directory \(ApplicationDirecrories.support.path)"
        
        throw CoreDataError.couldNotCreateCoordinator(failureReason)
    }
    
    let coordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    let url = ApplicationDirecrories.support.appendingPathComponent(config.fileName)
    
    try coordinator.addPersistentStore(ofType: config.type,
                                       configurationName: nil,
                                       at: url,
                                       options: config.options)
    
    return coordinator
}

private func createContext(_ coordinator: NSPersistentStoreCoordinator) -> NSManagedObjectContext {
    
    let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    moc.persistentStoreCoordinator = coordinator
    moc.undoManager = nil
    
    return moc
}
