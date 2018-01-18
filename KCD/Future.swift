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
    
    case error(Error)
}

private let watingQueue = DispatchQueue(label: "Future", attributes: .concurrent)
class Future<T> {
    
    private let queue: DispatchQueue
    private let semaphore = DispatchSemaphore(value: 1)
    
    private var result: Result<T>?
    
    init(queue: DispatchQueue = watingQueue) {
        
        self.queue = queue
        
        self.semaphore.wait()
    }
    convenience init(queue: DispatchQueue = watingQueue, _ block: @escaping () throws -> T) {
        
        self.init(queue: queue)
        
        queue.async {
            do {
                self.success(try block())
            } catch {
                self.failure(error)
            }
        }
    }
    deinit {
        semaphore.signal()
    }
    
    @discardableResult
    func onSuccess(_ block: @escaping (T) -> Void) -> Self {
        
        queue.async {
            self.semaphore.wait()
            if case let .value(value)? = self.result { block(value) }
            self.semaphore.signal()
        }
        
        return self
    }
    
    @discardableResult
    func onFailure(_ block: @escaping (Error) -> Void) -> Self {
        
        queue.async {
            self.semaphore.wait()
            if case let .error(error)? = self.result { block(error) }
            self.semaphore.signal()
        }
        
        return self
    }
    
    func success(_ newValue: T) {
        
        switch result {
            
        case .none:
            result = .value(newValue)
            semaphore.signal()
            
        default:
            fatalError("multi call success(_:)")
        }
    }
    
    func failure(_ newError: Error) {
        
        switch result {
            
        case .none:
            result = .error(newError)
            semaphore.signal()
            
        default:
            fatalError("multi call failure(_:)")
        }
    }
    
    @discardableResult
    func await() -> Self {
        
        semaphore.wait()
        semaphore.signal()
        
        return self
    }
    
    func map<U>(_ transform: @escaping (T) throws -> U) -> Future<U> {
        
        return Future<U> {
            
            self.semaphore.wait()
            defer { self.semaphore.signal() }
            
            if case let .value(value)? = self.result {
                return try transform(value)
            }
            if case let .error(error)? = self.result {
                throw error
            }
            
            fatalError("Not reach")
        }
    }
    
    func flatMap<U>(_ transform: @escaping (T) -> Future<U>) -> Future<U> {
        
        let future = Future<U>()
        
        onSuccess {
            transform($0)
                .onSuccess { val in future.success(val) }
                .onFailure { error in future.failure(error) }
        }
        onFailure {
            future.failure($0)
        }
        
        return future
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
    ///     Returns: `T?` : 成功時は `T`, エラー時は例外を発生させる。 監視を継続するときは `nil`を返す
    /// - Returns: Notificationによって値が設定される Future<T>
    func future<T>(name: Notification.Name, object: Any?, block: @escaping (Notification) throws -> T?) -> Future<T> {
        
        let future = Future<T>()
        
        weak var token: NSObjectProtocol?
        token = self
            .addObserver(forName: name, object: object, queue: nil) { notification in
                
                do {
                    guard let value = try block(notification) else { return }
                    
                    future.success(value)
                } catch {
                    future.failure(error)
                }
                
                token.map(self.removeObserver)
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
    ///     Returns: `T?` : 成功時は `T`, エラー時は例外を発生させる。 監視を継続するときは `nil`を返す
    /// - Returns: CoreDataの更新で値が設定される Future<T>
    func future<T>(block: @escaping (Notification) throws -> T?) -> Future<T> {
        
        return NotificationCenter.default
            .future(name: .NSManagedObjectContextObjectsDidChange, object: self.context, block: block)
    }
}
