//
//  CacheStoragePolicy.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

private func cacheable(status: Int) -> Bool {
    switch status {
    case 200, 203, 206,
         301, 304,
         404, 410:
        return true
    default:
        return false
    }
}

private func cacheable(response: HTTPURLResponse) -> Bool {
    guard let cc = response.allHeaderFields["Cache-Control"] as? String,
        let _ = cc.lowercased().range(of: "no-store")
        else { return true }
    return false
}

private func cacheable(request: URLRequest) -> Bool {
    guard let cc: String = request.allHTTPHeaderFields?["Cache-Control"]
        else { return true }
    if let _ = cc.lowercased().range(of: "no-store") { return false }
    if let _ = cc.lowercased().range(of: "no-cache") { return false }
    return true
}

private func policy(request: URLRequest) -> URLCache.StoragePolicy {
    if let scheme = request.url?.scheme?.lowercased(),
        scheme == "https"
    { return .allowedInMemoryOnly }
    return .allowed
}

func CacheStoragePolicy(for request: URLRequest, response: HTTPURLResponse) -> URLCache.StoragePolicy {
    if cacheable(status: response.statusCode),
        cacheable(response: response),
        cacheable(request: request)
    {
        return policy(request: request)
    }
    return .notAllowed
}
