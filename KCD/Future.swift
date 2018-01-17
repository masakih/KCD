//
//  Future.swift
//  KCD
//
//  Created by Hori,Masaki on 2018/01/13.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Cocoa


enum Result<T> {
    
    case value(T)
    case none
    case error(Error)
}

private let watingQueue = DispatchQueue(label: "Future", attributes: .concurrent)
class Future<T> {
    
    private let queue: DispatchQueue
    private let semaphore = DispatchSemaphore(value: 1)
    
    private var result: Result<T> = .none
    
    init(queue: DispatchQueue = watingQueue) {
        
        self.queue = queue
        
        self.semaphore.wait()
    }
    deinit {
        semaphore.signal()
    }
    
    @discardableResult
    func onSuccess(block: @escaping (T) -> Void) -> Future<T> {
        
        queue.async {
            
            self.semaphore.wait()
            if case .value(let value) = self.result { block(value) }
            self.semaphore.signal()
        }
        
        return self
    }
    
    @discardableResult
    func onFailure(block: @escaping (Error) -> Void) -> Future<T> {
        
        queue.async {
            
            self.semaphore.wait()
            if case .error(let error) = self.result { block(error) }
            self.semaphore.signal()
        }
        
        return self
    }
    
    func success(_ value: T) {
        
        switch result {
            
        case .value, .error:
            Logger.shared.log("multi call success(_:)")
            fatalError()
            
        case .none:
            result = .value(value)
            semaphore.signal()
        }
    }
    
    func failure(_ error: Error) {
        
        switch result {
            
        case .value, .error:
            Logger.shared.log("multi call failure(_:)")
            fatalError()
            
        case .none:
            result = .error(error)
            semaphore.signal()
        }
    }
}


extension NotificationCenter {
    
    /// Notificationを待って値が設定される Future<T>を返す
    ///
    /// - Parameters:
    ///   - name: Notification.Name
    ///   - object: 監視対象
    ///   - block:
    ///     Parameters: Notification
    ///     Returns: `Result<T>` : 成功時は `.value<T>`, エラー時は `.error<Error>`, 監視を継続するときは `.none`を返す
    /// - Returns: Notificationによって値が設定される Future<T>
    func future<T>(name: Notification.Name, object: Any?, block: @escaping (Notification) -> Result<T>) -> Future<T> {
        
        let future = Future<T>()
        
        weak var token: NSObjectProtocol?
        token = self
            .addObserver(forName: name,
                         object: object,
                         queue: nil) { notification in
                            
                            switch block(notification) {
                                
                            case .value(let val): future.success(val)
                                
                            case .none: return
                                
                            case .error(let error): future.failure(error)
                            }
                            
                            token.map(NotificationCenter.default.removeObserver)
        }
        
        return future
    }
}

extension CoreDataProvider {
    
    /// 初回起動時などにデータがない時などにCoreDataを監視し値が設定される Future<T>を返す
    ///
    /// - Parameters:
    ///   - block:
    ///     Parameters: Notification (NSManagedObjectContextObjectsDidChange)
    ///     Returns: `Result<T>` : 成功時は `.value<T>`, エラー時は `.error<Error>`, 監視を継続するときは `.none`を返す
    /// - Returns: CoreDataの更新で値が設定される Future<T>
    func future<T>(block: @escaping (Notification) -> Result<T>) -> Future<T> {
        
        return NotificationCenter.default
            .future(name: .NSManagedObjectContextObjectsDidChange, object: self.context, block: block)
    }
}
