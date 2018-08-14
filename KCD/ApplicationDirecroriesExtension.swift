//
//  ApplicationDirecroriesExtension.swift
//  KCD
//
//  Created by Hori,Masaki on 2018/04/16.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

extension ApplicationDirecrories {
    
    var screenshotSaveDirectoryURL: URL {
        
        let parentURL = URL(fileURLWithPath: screenShotSaveDirectory)
        let url = parentURL.appendingPathComponent(localizedAppName())
        
        guard checkDirectory(url, create: true) else { return parentURL }
        
        return url
    }
    
    var screenShotSaveDirectory: String {
        
        return UserDefaults.standard[.screenShotSaveDirectory] ?? ApplicationDirecrories.pictures.path
    }
    
    func setScreenshotDirectory(_ newValue: String) {
        
        UserDefaults.standard[.screenShotSaveDirectory] = newValue
    }
}
