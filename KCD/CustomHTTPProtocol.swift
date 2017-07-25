//
//  CustomHTTPProtocol.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/10.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa


protocol CustomHTTPProtocolDelegate: class {
    
    func customHTTPProtocol(_ proto: CustomHTTPProtocol, didRecieve response: URLResponse)
    func customHTTPProtocol(_ proto: CustomHTTPProtocol, didRecieve data: Data)
    func customHTTPProtocolDidFinishLoading(_ proto: CustomHTTPProtocol)
    func customHTTPProtocol(_ proto: CustomHTTPProtocol, didFailWithError error: Error)
}

fileprivate final class ThreadOperator: NSObject {
    
    private let thread: Thread
    private let modes: [String]
    private var operation: (() -> Void)?
    
    override init() {
        
        thread = Thread.current
        let mode = RunLoop.current.currentMode ?? .defaultRunLoopMode
        
        if mode == .defaultRunLoopMode {
            
            modes = [mode.rawValue]
            
        } else {
            
            modes = [mode, .defaultRunLoopMode].map { $0.rawValue }
        }
        
        super.init()
    }
    
    func execute(_ operation: @escaping () -> Void) {
        
        self.operation = operation
        perform(#selector(ThreadOperator.operate),
                on: thread,
                with: nil,
                waitUntilDone: true,
                modes: modes)
        self.operation = nil
    }
    
    func operate() {
        
        operation?()
    }
}

extension HTTPURLResponse {
    
    private var httpDateFormatter: DateFormatter {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"
        formatter.locale = Locale(identifier: "en_US")
        
        return formatter
    }
    
    func expires() -> Date? {
        
        if let cc = (allHeaderFields["Cache-Control"] as? String)?.lowercased(),
            let range = cc.range(of: "max-age="),
            let s = cc[range.upperBound..<cc.endIndex]
                .components(separatedBy: ",")
                .first,
            let age = TimeInterval(s) {
            
            return Date(timeIntervalSinceNow: age)
        }
        
        if let ex = (allHeaderFields["Expires"] as? String)?.lowercased(),
            let exp = httpDateFormatter.date(from: ex) {
            
            return exp
        }
        
        return nil
    }
}

extension URLCache {
    
    static let kcd = URLCache(memoryCapacity: 32 * 1024 * 1024,
                                      diskCapacity: 1024 * 1024 * 1024,
                                      diskPath: ApplicationDirecrories.support.appendingPathComponent("Caches").path)
    static let cachedExtensions = ["swf", "flv", "png", "jpg", "jpeg", "mp3"]
    
    func storeIfNeeded(for task: URLSessionTask, data: Data) {
        
        if let request = task.originalRequest,
            let response = task.response as? HTTPURLResponse,
            let ext = request.url?.pathExtension,
            URLCache.cachedExtensions.contains(ext),
            let expires = response.expires() {
            
            let cache = CachedURLResponse(response: response,
                                          data: data,
                                          userInfo: ["Expires": expires],
                                          storagePolicy: .allowed)
            storeCachedResponse(cache, for: request)
        }
    }
    
    func validCach(for request: URLRequest) -> CachedURLResponse? {
        
        if let cache = cachedResponse(for: request),
            let info = cache.userInfo,
            let expires = info["Expires"] as? Date,
            Date().compare(expires) == .orderedAscending {
            
                return cache
        }
        
        return nil
    }
}

final class CustomHTTPProtocol: URLProtocol {
    
    fileprivate static let requestProperty = "com.masakih.KCD.requestProperty"
    static var classDelegate: CustomHTTPProtocolDelegate?
    
    class func clearCache() { URLCache.kcd.removeAllCachedResponses() }
    class func start() { URLProtocol.registerClass(CustomHTTPProtocol.self) }
    
    override class func canInit(with request: URLRequest) -> Bool {
        
        if let _ = property(forKey: requestProperty, in: request) { return false }
        
        if let scheme = request.url?.scheme?.lowercased(),
            (scheme == "http" || scheme == "https") {
            
            return true
        }
        
        return false
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        
        return request
    }
    
    fileprivate var delegate: CustomHTTPProtocolDelegate? { return CustomHTTPProtocol.classDelegate }
    
    fileprivate var session: URLSession?
    fileprivate var dataTask: URLSessionDataTask?
    fileprivate var cachePolicy: URLCache.StoragePolicy = .notAllowed
    fileprivate var data: Data = Data()
    fileprivate var didRetry: Bool = false
    fileprivate var didRecieveData: Bool = false
    
    fileprivate var threadOperator: ThreadOperator?
    
    private func use(_ cache: CachedURLResponse) {
        
        delegate?.customHTTPProtocol(self, didRecieve: cache.response)
        client?.urlProtocol(self, didReceive: cache.response, cacheStoragePolicy: .allowed)
        
        delegate?.customHTTPProtocol(self, didRecieve: cache.data)
        client?.urlProtocol(self, didLoad: cache.data)
        
        delegate?.customHTTPProtocolDidFinishLoading(self)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func startLoading() {
        
        guard let newRequest = (request as NSObject).mutableCopy() as? NSMutableURLRequest
            else { fatalError("Can not convert to NSMutableURLRequest") }
        
        URLProtocol.setProperty(true,
                                forKey: CustomHTTPProtocol.requestProperty,
                                in: newRequest)
        
        if let cache = URLCache.kcd.validCach(for: request) {
            
            use(cache)
            
            Debug.excute(level: .full) {
                
                if let name = request.url?.lastPathComponent {
                    
                    print("Use cache for", name)
                    
                } else {
                    
                    print("Use cache")
                }
            }
            
            return
        }
        
        threadOperator = ThreadOperator()
        
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        dataTask = session?.dataTask(with: newRequest as URLRequest)
        dataTask?.resume()
    }
    
    override func stopLoading() {
        
        dataTask?.cancel()
    }
}

extension CustomHTTPProtocol: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        
        threadOperator?.execute { [weak self] in
            
            guard let `self` = self else { return }
            
            Debug.print("willPerformHTTPRedirection", level: .full)
            
            self.client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
            
            completionHandler(request)
        }
    }
    
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        threadOperator?.execute { [weak self] in
            
            guard let `self` = self else { return }
            
            Debug.print("didReceive response", level: .full)
            
            if let response = response as? HTTPURLResponse,
                let request = dataTask.originalRequest {
                
                self.cachePolicy = CacheStoragePolicy(for: request, response: response)
            }
            
            self.delegate?.customHTTPProtocol(self, didRecieve: response)
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: self.cachePolicy)
            
            completionHandler(.allow)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        threadOperator?.execute { [weak self] in
            
            guard let `self` = self else { return }
            
            Debug.print("didReceive data", level: .full)
            if self.cachePolicy == .allowed {
                
                self.data.append(data)
            }
            
            self.delegate?.customHTTPProtocol(self, didRecieve: data)
            self.client?.urlProtocol(self, didLoad: data)
            self.didRecieveData = true
        }
    }
    
    // cfurlErrorNetworkConnectionLost の場合はもう一度試す
    private func canRetry(error: NSError) -> Bool {
        
        guard error.code == Int(CFNetworkErrors.cfurlErrorNetworkConnectionLost.rawValue),
            !didRetry,
            !didRecieveData
            else { return false }
        
        print("Retry download...")
        
        return true
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        threadOperator?.execute { [weak self] in
            
            guard let `self` = self else { return }
            
            if let error = error {
                
                if self.canRetry(error: error as NSError),
                    let request = task.originalRequest {
                    
                    self.didRetry = true
                    self.dataTask = session.dataTask(with: request)
                    self.dataTask?.resume()
                    
                    return
                }
                
                Debug.print("didCompleteWithError ERROR", level: .full)
                
                self.delegate?.customHTTPProtocol(self, didFailWithError: error)
                self.client?.urlProtocol(self, didFailWithError: error)
                
                return
            }
            
            Debug.print("didCompleteWithError SUCCESS", level: .full)
            
            self.delegate?.customHTTPProtocolDidFinishLoading(self)
            self.client?.urlProtocolDidFinishLoading(self)
            
            if self.cachePolicy == .allowed {
                
                URLCache.kcd.storeIfNeeded(for: task, data: self.data)
            }
        }
    }
}
