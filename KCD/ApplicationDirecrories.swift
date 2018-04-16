//
//  ApplicationDirecrories.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

private func supportDirName() -> String {
    
    let main = Bundle.main
    
    return main.bundleIdentifier
        ?? main.infoDictionary?["CFBundleName"] as? String
        ?? main.infoDictionary?["CFBundleExecutable"] as? String
        ?? "UnknownAppliation"
}

func localizedAppName() -> String {
    
    guard let name = Bundle.main.localizedInfoDictionary?["CFBundleName"] as? String,
        !name.isEmpty else {
            
            return supportDirName()
    }
    
    return name
}

struct ApplicationDirecrories {
    
    static let support = searchedURL(for: .applicationSupportDirectory)
        .appendingPathComponent(supportDirName())
    
    static let documents = searchedURL(for: .documentDirectory)
    
    static let pictures = searchedURL(for: .picturesDirectory)
    
    private static func searchedURL(for directory: FileManager.SearchPathDirectory) -> URL {
        
        return FileManager.default.urls(for: directory, in: .userDomainMask)
            .last
            ?? URL(fileURLWithPath: NSHomeDirectory())
    }
}


func createDirectory(_ url: URL) -> Bool {
    
    do {
        
        try FileManager.default.createDirectory(at: url,
                                                withIntermediateDirectories: false,
                                                attributes: nil)
        
        return true
        
    } catch {
        
        return false
    }
}

func checkDirectory(_ url: URL, create: Bool) -> Bool {
    
    do {
        
        let resourceValue = try url.resourceValues(forKeys: [.isDirectoryKey])
        if !resourceValue.isDirectory! {
            
            print("Expected a folder to store application data, found a file \(url.path).")
            
            return false
        }
        
        return true
        
    } catch let error as NSError {
        
        if create, error.code == NSFileReadNoSuchFileError {
            
            return createDirectory(url)
        }
        
        return false
    }
}
