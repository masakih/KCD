//
//  NSObjectExtension.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

extension NSObject {
    
    func notifyChangeValue(forKey key: String) {
        
        willChangeValue(forKey: key)
        didChangeValue(forKey: key)
    }
    
    func notifyChangeValue(forKey key: String, change f: () -> Void) {
        
        willChangeValue(forKey: key)
        f()
        didChangeValue(forKey: key)
    }
}
