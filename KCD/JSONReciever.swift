//
//  JSONReciever.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class JSONReciever {
    
    private let queue: Queue<APIResponse>
    private var recievers: [URLProtocol: NSMutableData] = [:]
    
    init(queue: Queue<APIResponse>) {
        
        self.queue = queue
        CustomHTTPProtocol.classDelegate = self
    }
}

extension JSONReciever: CustomHTTPProtocolDelegate {
    
    private func storeData(for proto: URLProtocol) {
        
        recievers[proto] = NSMutableData()
        
        Debug.print("Accept protorol ->", proto, level: .full)
    }
    
    private func data(for proto: URLProtocol) -> NSMutableData? {
        
        return recievers[proto]
    }
    
    private func releaseeData(for proto: URLProtocol) {
        
        recievers[proto] = nil
    }
    
    func customHTTPProtocol(_ proto: CustomHTTPProtocol, didRecieve response: URLResponse) {
        
        if let pathComp = proto.request.url?.pathComponents,
            pathComp.contains("kcsapi") {
            
            storeData(for: proto)
        }
    }
    
    func customHTTPProtocol(_ proto: CustomHTTPProtocol, didRecieve data: Data) {
        
        self.data(for: proto)?.append(data)
    }
    
    func customHTTPProtocolDidFinishLoading(_ proto: CustomHTTPProtocol) {
        
        defer { releaseeData(for: proto) }
        
        guard let data = self.data(for: proto),
            let response = APIResponse(request: proto.request, data: data as Data) else {
                
                return
        }
        
        queue.enqueue(response)
    }
    
    func customHTTPProtocol(_ proto: CustomHTTPProtocol, didFailWithError error: Error) {
        
        Debug.print("Connection Error! \nRequest: \(proto.request)\nError:\(error)", level: .full)
        
        releaseeData(for: proto)
    }
}
