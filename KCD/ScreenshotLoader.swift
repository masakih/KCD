//
//  ScreenshotLoader.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/11/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class ScreenshotLoader {
    
    let url: URL
    
    init(_ url: URL) {
        
        self.url = url
    }
    
    func merge(screenshots: [ScreenshotInformation]) -> [ScreenshotInformation] {
        
        let urls = screenshotURLs()
        
        // なくなっているものを削除
        let itemWithoutDeleting = screenshots.filter { urls.contains($0.url) }
        
        // 新しいものを追加
        let newItems = urls
            .filter { url in !itemWithoutDeleting.contains(where: { url == $0.url }) }
            .map { ScreenshotInformation(url: $0) }
        
        return itemWithoutDeleting + newItems
    }
    
    private func screenshotURLs() -> [URL] {
        
        guard let files = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) else {
            
            Logger.shared.log("can not read list of screenshot directory")
            
            return []
        }
        
        return files.filter(isPicture)
    }
    
    private func isPicture(_ url: URL) -> Bool {
                
        guard let r = try? url.resourceValues(forKeys: [.typeIdentifierKey]) else {
            
            return false
        }
        guard let type = r.typeIdentifier else {
            
            return false
        }
        
        return NSImage.imageTypes.contains(type)
    }
}
