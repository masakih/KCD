//
//  ManagedObjectContextGenerator.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/21.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class MOCGenerator {
    
    let config: CoreDataConfiguration
    
    init(_ config: CoreDataConfiguration) {
        
        self.config = config
    }
    
    func genarate() throws -> (model: NSManagedObjectModel, coordinator: NSPersistentStoreCoordinator, moc: NSManagedObjectContext) {
        
        let model = try createModel()
        let coordinator = try createCoordinator(model)
        let moc = createContext(coordinator)
        
        return (model: model, coordinator: coordinator, moc: moc)
    }
    
    static func removeDataFile(_ config: CoreDataConfiguration) {
        
        ["", "-wal", "-shm"]
            .map { config.fileName + $0 }
            .map(ApplicationDirecrories.support.appendingPathComponent)
            .forEach(removeFile)
    }
    
    private static func removeFile(at url: URL) {
        
        do {
            
            try FileManager.default.removeItem(at: url)
            
        } catch {
            
            print("Could not remove file for URL (\(url))")
        }
    }
    
    // MARK: - NSManagedObjectContext and ...
    private func createModel() throws -> NSManagedObjectModel {
        
        guard let modelURL = Bundle.main.url(forResource: config.modelName, withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL) else {
                
                throw CoreDataError.couldNotCreateModel
        }
        
        return model
    }
    
    private func createCoordinator(_ model: NSManagedObjectModel) throws -> NSPersistentStoreCoordinator {
        
        if !checkDirectory(ApplicationDirecrories.support) {
            
            throw CoreDataError.saveLocationIsUnuseable
        }
        
        do {
            
            return try makeCoordinator(model)
            
        } catch (let error as NSError) {
            
            // Data Modelが更新されていたらストアファイルを削除してもう一度
            if error.domain == NSCocoaErrorDomain,
                (error.code == 134130 || error.code == 134110),
                config.tryRemake {
                
                MOCGenerator.removeDataFile(config)
                
                do {
                    
                    return try makeCoordinator(model)
                    
                } catch {
                    
                    print("Fail to create NSPersistentStoreCoordinator twice.")
                }
            }
            
            throw CoreDataError.couldNotCreateCoordinator(error.localizedDescription)
        }
    }
    
    private func makeCoordinator(_ model: NSManagedObjectModel) throws -> NSPersistentStoreCoordinator {
        
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
}
