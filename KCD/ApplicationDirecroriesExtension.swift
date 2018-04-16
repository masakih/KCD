//
//  ApplicationDirecroriesExtension.swift
//  KCD
//
//  Created by Hori,Masaki on 2018/04/16.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

extension ApplicationDirecrories {
    
    static let screenshotSaveDirectoryURL: URL = {
        
        let parentURL = URL(fileURLWithPath: AppDelegate.shared.screenShotSaveDirectory)
        let url = parentURL.appendingPathComponent(localizedAppName())
        let fm = FileManager.default
        var isDir: ObjCBool = false
        
        do {
            
            if !fm.fileExists(atPath: url.path, isDirectory: &isDir) {
                
                try fm.createDirectory(at: url, withIntermediateDirectories: false)
                
            } else if !isDir.boolValue {
                
                print("\(url) is regular file, not direcory.")
                
                return parentURL
            }
            
        } catch {
            
            print("Can not create screenshot save directory.")
            
            return parentURL
        }
        
        return url
    }()
}
