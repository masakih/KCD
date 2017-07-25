//
//  FileManagerExtension.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

extension FileManager {
    
    func uniqueFileURL(_ url: URL) -> URL {
        
        let fileName = _web_pathWithUniqueFilename(forPath: url.path)
        
        return URL(fileURLWithPath: fileName)
    }
}
