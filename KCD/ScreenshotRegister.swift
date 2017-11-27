//
//  ScreenshotRegister.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/11/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class ScreenshotRegister {
    
    
    let url: URL
    
    init(_ url: URL) {
        
        self.url = url
    }
    
    func registerScreenshot(_ image: NSBitmapImageRep, name: String, completeHandler: @escaping (URL) -> Void) {
        
        DispatchQueue(label: "Screenshot queue").async {
            
            let size = image.size
            if size != NSSize(width: 800, height: 480) {
                image.size = NSSize(width: 800, height: 480)
            }
            
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
            
            DispatchQueue.main.async {
                
                completeHandler(pathURL)
            }
        }
    }
}
