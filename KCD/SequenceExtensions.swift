//
//  SequenceExtensions.swift
//  KCD
//
//  Created by Hori,Masaki on 2018/08/05.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

// powered by http://stackoverflow.com/questions/40579554/how-to-display-unique-elements-of-an-array-using-swift
extension Sequence where Element: Hashable {
    
    func unique() -> [Element] {
        
        var alreadyAdded = Set<Element>()
        
        return filter {
            
            if alreadyAdded.contains($0) {
                
                return false
            }
            
            alreadyAdded.insert($0)
            
            return true
        }
    }
}

extension Sequence {
    
    func noneOp(_ f: (Self) -> Void) -> Self {
        
        f(self)
        
        return self
    }
}
