//
//  ManagedObjectContextGenerator.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/21.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

enum CoreDataError: Error {
    case applicationDirectoryIsFile
    case couldNotCreateModel
    case couldNotCreateCoordinator(String)
}

func remove(name: String) {
    ["", "-wal", "-shm"]
        .map { name + $0 }
        .map { ApplicationDirecrories.support.appendingPathComponent($0) }
        .forEach { removeDataFile(at: $0) }
}

func genarate(_ info: CoreDataIntormation) throws ->
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

private func removeDataFile(at url: URL) {
    do {
        try FileManager.default.removeItem(at: url)
    } catch {
        print("Could not remove file for URL (\(url))")
    }
}

// MARK: - NSManagedObjectContext and ...
private  func createModel(_ info: CoreDataIntormation) throws -> NSManagedObjectModel {
    guard let modelURL = Bundle.main.url(forResource: info.modelName, withExtension: "momd"),
        let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
            throw CoreDataError.couldNotCreateModel
    }
    return model
}
private func getCoordinator(_ info: CoreDataIntormation,
                            _ model: NSManagedObjectModel) throws -> NSPersistentStoreCoordinator {
    do {
        return try createCoordinator(info, model)
    } catch {
        let nserror = error as NSError
        // Data Modelが更新されていたらストアファイルを削除してもう一度
        if nserror.domain == NSCocoaErrorDomain,
            (nserror.code == 134130 || nserror.code == 134110),
            info.tryRemake {
            remove(name: info.fileName)
            do {
                return try createCoordinator(info, model)
            } catch {
                print("Fail crrate NSPersistentStoreCoordinator twice.")
            }
        }
        throw error
    }
}
private func createCoordinator(_ info: CoreDataIntormation,
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
private func createContext(_ coordinator: NSPersistentStoreCoordinator) -> NSManagedObjectContext {
    let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    moc.persistentStoreCoordinator = coordinator
    moc.undoManager = nil
    return moc
}
