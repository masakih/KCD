//
//  ScreenshotRegister.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/11/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa


extension Notification.Name {
    
    static let didRegisterScreenshot = Notification.Name(rawValue: "ScreenshotRegister.didRegisterScreenshot")
}

class ScreenshotRegister {
    
    static let screenshotURLKey = "ScreenshotRegister.screenshotURLKey"
    
    let url: URL
    
    init(_ url: URL) {
        
        self.url = url
    }
    
    func registerScreenshot(_ image: NSBitmapImageRep, name: String) {
        
        DispatchQueue(label: "Screenshot queue").async {
            
            guard let data = image.representation(using: .jpeg, properties: [:]) else { return }
            
            let url = self.url
                .appendingPathComponent(name)
                .appendingPathExtension("jpg")
            let pathURL = FileManager.default.uniqueFileURL(url)
            
            do {
                
                try data.write(to: pathURL)
                
            } catch {
                
                print("Can not write image")
                return
            }
            
            self.notify(url: pathURL)
        }
    }
    
    func notify(url: URL) {
        
        DispatchQueue.main.async {
            NotificationCenter.default
                .post(name: .didRegisterScreenshot,
                      object: self,
                      userInfo: [ScreenshotRegister.screenshotURLKey: url])
        }
    }
    
}
