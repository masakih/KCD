//
//  DockInformationFutures.swift
//  KCD
//
//  Created by Hori,Masaki on 2018/01/14.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Cocoa

/// 値にはType名が入る
enum DockInformationError: Error {
    
    case outOfBounds(String)
    
    case canNotCreate(String)
}

protocol DockInformationFutureCreatable {
    
    static func valid(number: Int) -> Bool
    static func alreadyHasData(for: Int) -> Bool
    
    init?(number: Int)
}

func createDockInformationFuture<T: DockInformationFutureCreatable>(number: Int) -> Future<T> {
    
    func storeInformation(to future: Future<T>) {
        
        guard let status = T.init(number: number) else {
            
            future.failure(DockInformationError.canNotCreate(String(describing: T.self)))
            return
        }
        future.success(status)
    }
    
    let future = Future<T>()
    
    guard T.valid(number: number) else {
        
        future.failure(DockInformationError.outOfBounds(String(describing: T.self)))
        return future
    }
    
    if T.alreadyHasData(for: number) {
        
        storeInformation(to: future)
        return future
    }
    
    // 初回起動時などはデータがない
    // CoreDataを監視して作成されるのを待つ
    weak var token: NSObjectProtocol?
    token = NotificationCenter.default
        .addObserver(forName: .NSManagedObjectContextObjectsDidChange,
                     object: ServerDataStore.default.context,
                     queue: nil) { _ in
                        
                        if T.alreadyHasData(for: number) {
                            
                            storeInformation(to: future)
                            
                            token.map(NotificationCenter.default.removeObserver)
                        }
    }
    
    return future
}

extension MissionStatus: DockInformationFutureCreatable {
    
    static func alreadyHasData(for number: Int) -> Bool {
        
        return ServerDataStore.default.deck(by: number) != nil
    }
}

func createMissionSatusFuture(number: Int) -> Future<MissionStatus> {
    
    return createDockInformationFuture(number: number)
}

extension NyukyoDockStatus: DockInformationFutureCreatable {
    
    static func alreadyHasData(for number: Int) -> Bool {
        
        return ServerDataStore.default.nyukyoDock(by: number) != nil
    }
}

func createNyukyoDockStatusFuture(number: Int) -> Future<NyukyoDockStatus> {
    
    return createDockInformationFuture(number: number)
}

extension KenzoDockStatus: DockInformationFutureCreatable {
        
    static func alreadyHasData(for number: Int) -> Bool {
        
        return ServerDataStore.default.kenzoDock(by: number) != nil
    }
}

func createKenzoDockStatusFuture(number: Int) -> Future<KenzoDockStatus> {
    
    return createDockInformationFuture(number: number)
}
