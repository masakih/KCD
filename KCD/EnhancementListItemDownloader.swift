//
//  EnhancementListItemDownloader.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/12/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

final class EnhancementListItemDownloader: NSObject, URLSessionDownloadDelegate {
    
    private let resourceName: String
    private let resourceExtension: String
    
    init(name: String, extension ext: String) {
        
        self.resourceName = name
        self.resourceExtension = ext
        
        super.init()
        
        plistDownloadQueue = OperationQueue()
        plistDownloadQueue.name = "StrengthenListViewControllerPlistDownloadQueue"
        plistDownloadQueue.maxConcurrentOperationCount = 1
        plistDownloadQueue.qualityOfService = .background
        
        let configuration = URLSessionConfiguration.default
        
        plistDownloadSession = URLSession(configuration: configuration,
                                          delegate: self,
                                          delegateQueue: plistDownloadQueue)
    }
    
    private var plistDownloadSession: URLSession!
    private var plistDownloadQueue: OperationQueue!
    private var plistDownloadTask: URLSessionDownloadTask?
    private var finishOperation: (([EnhancementListItem]) -> Void)?
    
    func download(completeHandler: @escaping ([EnhancementListItem]) -> Void) {
        
        if let _ = plistDownloadTask {
            
            return
        }
        
        guard let plistURL = URL(string: "https://osdn.net/projects/kcd/scm/git/KCD/blobs/master/KCD/\(resourceName).\(resourceExtension)?export=raw") else {
            
            return
        }
        
        finishOperation = completeHandler
        plistDownloadTask = plistDownloadSession.downloadTask(with: plistURL)
        plistDownloadTask?.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        plistDownloadTask = nil
        
        guard let data = try? Data(contentsOf: location, options: []) else {
            
            return
        }
        guard let list = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [EnhancementListItem] else {
            
            return
        }
        
        finishOperation?(list)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if let error = error {
            
            Logger.shared.log(error.localizedDescription)
        }
        plistDownloadTask = nil
    }
}
