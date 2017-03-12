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

class CustomHTTPProtocol: URLProtocol {
    fileprivate static let requestProperty = "com.masakih.KCD.requestProperty"
    static var classDelegate: CustomHTTPProtocolDelegate? = nil
    fileprivate static let cachedExtensions = ["swf", "flv", "png", "jpg", "jpeg", "mp3"]
    fileprivate static let cacheFileURL: URL = ApplicationDirecrories.support.appendingPathComponent("Caches")
    fileprivate static let kcdURLCache = URLCache(memoryCapacity: 32 * 1024 * 1024,
                                                  diskCapacity: 1024 * 1024 * 1024,
                                                  diskPath: cacheFileURL.path)
    
    class func clearCache() { kcdURLCache.removeAllCachedResponses() }
    class func start() { URLProtocol.registerClass(CustomHTTPProtocol.self) }
    
    override class func canInit(with request: URLRequest) -> Bool {
        if let _ = property(forKey: requestProperty, in: request) { return false }
        if let scheme = request.url?.scheme?.lowercased(),
            (scheme == "http" || scheme == "https")
        { return true }
        return false
    }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    fileprivate var delegate: CustomHTTPProtocolDelegate? { return CustomHTTPProtocol.classDelegate }
    
    fileprivate var session: URLSession? = nil
    fileprivate var dataTask: URLSessionDataTask? = nil
    fileprivate var cachePolicy: URLCache.StoragePolicy = .notAllowed
    fileprivate var data: Data = Data()
    fileprivate var didRetry: Bool = false
    fileprivate var didRecieveData: Bool = false
    
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
        CustomHTTPProtocol.setProperty(true,
                                       forKey: CustomHTTPProtocol.requestProperty,
                                       in: newRequest)
        
        if let cache = CustomHTTPProtocol.kcdURLCache.cachedResponse(for: request),
            let info = cache.userInfo,
            let expires = info["Expires"] as? Date,
            Date().compare(expires) == .orderedAscending
        {
            use(cache)
            if let name = request.url?.lastPathComponent {
                Debug.print("Use cache for", name, level: .full)
            } else {
                Debug.print("Use cache", level: .full)
            }
            
            return
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [type(of: self)]
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
        Debug.print("willPerformHTTPRedirection", level: .full)
        client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
        completionHandler(request)
    }
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        Debug.print("didReceive response", level: .full)
        
        if let response = response as? HTTPURLResponse,
            let request = dataTask.originalRequest {
            cachePolicy = CacheStoragePolicy(for: request, response: response)
        }
        
        delegate?.customHTTPProtocol(self, didRecieve: response)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: cachePolicy)
        completionHandler(.allow)
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        Debug.print("didReceive data", level: .full)
        if cachePolicy == .allowed {
            self.data.append(data)
        }
        delegate?.customHTTPProtocol(self, didRecieve: data)
        client?.urlProtocol(self, didLoad: data)
        didRecieveData = true
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
        if let error = error {
            if canRetry(error: error as NSError),
                let request = task.originalRequest
            {
                didRetry = true
                dataTask = session.dataTask(with: request)
                dataTask?.resume()
                return
            }
            Debug.print("didCompleteWithError ERROR", level: .full)
            delegate?.customHTTPProtocol(self, didFailWithError: error)
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        Debug.print("didCompleteWithError SUCCESS", level: .full)
        delegate?.customHTTPProtocolDidFinishLoading(self)
        client?.urlProtocolDidFinishLoading(self)
        
        if cachePolicy == .allowed,
            let ext = task.originalRequest?.url?.pathExtension,
            CustomHTTPProtocol.cachedExtensions.contains(ext),
            let request = task.originalRequest,
            let response = task.response as? HTTPURLResponse,
            let expires = response.expires()
        {
            let cache = CachedURLResponse(response: response,
                                          data: data,
                                          userInfo: ["Expires": expires],
                                          storagePolicy: .allowed)
            CustomHTTPProtocol.kcdURLCache.storeCachedResponse(cache, for: request)
        }
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
            let age = TimeInterval(s)
        {
            return Date(timeIntervalSinceNow: age)
        }
        if let ex = (allHeaderFields["Expires"] as? String)?.lowercased(),
            let exp = httpDateFormatter.date(from: ex)
        {
            return exp
        }
        return nil
    }
}
