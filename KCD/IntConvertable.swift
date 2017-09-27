//
//  IntConvertable.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/09/27.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

protocol IntConvertable {
    
    func toInt() -> Int
}
extension Int: IntConvertable {
    
    func toInt() -> Int {
        
        return self
    }
}
extension String: IntConvertable {
    
    func toInt() -> Int {
        
        return Int(self) ?? 0
    }
}
extension NSNumber: IntConvertable {
    
    func toInt() -> Int {
        
        return self.intValue
    }
}
