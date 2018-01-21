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
    
    init(_ value: T) {
        self = .value(value)
    }
    init(_ error: Error) {
        self = .error(error)
    }
}

enum FutureError: Error {
    
    case unsolvedFuture
    
    case noSuchElement
}

private let defaultWaitingQueue = DispatchQueue(label: "Future", attributes: .concurrent)
private final class FutureSynchronous {
    
    private let queue: DispatchQueue
    private let semaphore = DispatchSemaphore(value: 1)
    
    init(queue: DispatchQueue = defaultWaitingQueue) {
        self.queue = queue
    }
    
    func excuteAfterWaiting(_ block: @escaping () -> Void) {
        
        queue.async {
            self.semaphore.wait()
            block()
            self.semaphore.signal()
        }
    }
    
    func startWaiting() {
        self.semaphore.wait()
    }
    
    func stopWaiting() {
        self.semaphore.signal()
    }
}

class Future<T> {
    
    private let synchronous: FutureSynchronous
    
    fileprivate var result: Result<T>? {
        willSet {
            if result != nil {
                fatalError("Result already seted")
            }
        }
        didSet {
            synchronous.stopWaiting()
        }
    }
    
    /// Life cycle
    init(queue: DispatchQueue? = nil) {
        
        self.synchronous = queue.map { FutureSynchronous(queue: $0) } ?? FutureSynchronous()
        
        synchronous.startWaiting()
    }
    
    init(queue: DispatchQueue? = nil, _ block: @escaping () throws -> T) {
        
        self.synchronous = queue.map { FutureSynchronous(queue: $0) } ?? FutureSynchronous()
        
        synchronous.excuteAfterWaiting {
            do {
                self.result = Result(try block())
            } catch {
                self.result = Result(error)
            }
        }
    }
    
    init(queue: DispatchQueue? = nil, _ result: Result<T>) {
        
        self.synchronous = queue.map { FutureSynchronous(queue: $0) } ?? FutureSynchronous()
        
        self.result = result
    }
    convenience init(_ value: T) {
        
        self.init(Result(value))
    }
    convenience init(_ error: Error) {
        
        self.init(Result(error))
    }
    
    deinit {
        synchronous.stopWaiting()
    }
    
}

extension Future {
    ///
    @discardableResult
    func await() -> Self {
        
        synchronous.excuteAfterWaiting {
            // do nothing
        }
        
        return self
    }
    
    @discardableResult
    func onComplete(_ block: @escaping (Result<T>) -> Void) -> Self {
        
        synchronous.excuteAfterWaiting {
            block(self.result!)
        }
        
        return self
    }
    
    @discardableResult
    func onSuccess(_ block: @escaping (T) -> Void) -> Self {
        
        synchronous.excuteAfterWaiting {
            if case let .value(value)? = self.result { block(value) }
        }
        
        return self
    }
    
    @discardableResult
    func onFailure(_ block: @escaping (Error) -> Void) -> Self {
        
        synchronous.excuteAfterWaiting {
            if case let .error(error)? = self.result { block(error) }
        }
        
        return self
    }
}

extension Future {
    
    ///
    func transform<U>(_ s: @escaping (T) -> U, _ f: @escaping (Error) -> (Error)) -> Future<U> {
        
        return transform {
            switch $0 {
                
            case let .value(value): return Result(s(value))
                
            case let .error(error): return Result(f(error))
            }
        }
    }
    
    func transform<U>(_ s: @escaping (Result<T>) -> Result<U>) ->Future<U> {
        
        return Promise()
            .complete {
                guard let r = self.await().result.map({s($0)}) else {
                    return Result(FutureError.unsolvedFuture)
                }
                return r
            }
            .future
    }
    
    func map<U>(_ t: @escaping (T) -> U) -> Future<U> {
        
        return transform(t, { $0 })
    }
    
    func flatMap<U>(_ t: @escaping (T) -> Future<U>) -> Future<U> {
        
        return Promise()
            .completeWith {
                switch self.await().result {
                case let .value(v)?: return t(v)
                case let .error(e)?: return Future<U>(e)
                case .none: return Future<U>(FutureError.unsolvedFuture)
                }
            }
            .future
    }
    
    func filter(_ f: @escaping (T) -> Bool) -> Future<T> {
        
        return Promise()
            .complete {
                if case let .value(v)? = self.result, f(v) {
                    return Result(v)
                }
                return Result(FutureError.noSuchElement)
            }
            .future
    }
    
    func recover(_ s: @escaping (Error) throws -> T) -> Future<T> {
        
        return transform {
            do {
                if case let .error(e) = $0 {
                    return Result(try s(e))
                }
            } catch {
                return Result(error)
            }
            return $0
        }
    }
}

fileprivate extension Future {
    
    func complete(_ result: Result<T>) {
        
        self.result = result
    }
}

private let promiseQueue = DispatchQueue(label: "Promise", attributes: .concurrent)
final class Promise<T> {
    
    let future: Future<T> = Future<T>()
    
    ///
    func complete(_ result: Result<T>) {
        
        future.complete(result)
    }
    func success(_ value: T) {
        
        complete(Result(value))
    }
    func failure(_ error: Error) {
        
        complete(Result(error))
    }
    
    func complete(_ completor: @escaping () -> Result<T>) -> Self {
        
        promiseQueue.async {
            self.complete(completor())
        }
        
        return self
    }
    
    func completeWith(_ completor: @escaping () -> Future<T>) -> Self {
        
        promiseQueue.async {
            completor()
                .onSuccess {
                    self.success($0)
                }
                .onFailure {
                    self.failure($0)
            }
        }
        
        return self
    }
}
