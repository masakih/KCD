//
//  JSONReciever.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class JSONReciever {
    
    init(queue: Queue<APIResponse>) {
        
        self.queue = queue
        CustomHTTPProtocol.classDelegate = self
    }
    
    fileprivate let queue: Queue<APIResponse>
    fileprivate var recievers: [URLProtocol: NSMutableData] = [:]
}

extension JSONReciever: CustomHTTPProtocolDelegate {
    
    private func acceptProtocol(_ proto: URLProtocol) {
        
        recievers[proto] = NSMutableData()
        
        Debug.print("Accept protorol ->", proto, level: .full)
    }
    
    private func data(_ forProtocol: URLProtocol) -> NSMutableData? {
        
        return recievers[forProtocol]
    }
    
    private func clearProtocol(_ proto: URLProtocol) {
        
        recievers[proto] = nil
    }
    
    func customHTTPProtocol(_ proto: CustomHTTPProtocol, didRecieve response: URLResponse) {
        
        if let pathComp = proto.request.url?.pathComponents,
            pathComp.contains("kcsapi") {
            
            acceptProtocol(proto)
        }
    }
    
    func customHTTPProtocol(_ proto: CustomHTTPProtocol, didRecieve data: Data) {
        
        self.data(proto)?.append(data)
    }
    
    func customHTTPProtocolDidFinishLoading(_ proto: CustomHTTPProtocol) {
        
        defer { clearProtocol(proto) }
        
        guard let data = self.data(proto),
            let response = APIResponse(request: proto.request, data: data as Data)
            else { return }
        
        queue.enqueue(response)
    }
    
    func customHTTPProtocol(_ proto: CustomHTTPProtocol, didFailWithError error: Error) {
        
        Debug.print("Connection Error! \nRequest: \(proto.request)\nError:\(error)", level: .full)
        
        clearProtocol(proto)
    }
}
