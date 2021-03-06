//
//  ArrayExtensions.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/01.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

extension Array {
    
    func appended(_ elem: () -> Element) -> Array {
        
        return self + [elem()]
    }
}

infix operator ==? : ComparisonPrecedence
func ==? <T: Comparable> (lhv: T, rhv: T) -> ComparisonResult {
    
    if lhv == rhv {
        
        return .orderedSame
    }
    if lhv < rhv {
        
        return .orderedAscending
    }
    
    return .orderedDescending
}

extension MutableCollection {
    
    private func bsearch(min: Int, max: Int, comparator: (Iterator.Element) -> ComparisonResult) -> Iterator.Element? {
        
        if max < min {
            
            return nil
        }
        
        let current = min + (max - min) / 2
        let v = self[self.index(self.startIndex, offsetBy: current)]
        let compRes = comparator(v)
        
        if compRes == .orderedSame {
            
            return v
        }
        
        let newMin = (compRes == .orderedAscending) ? current + 1 : min
        let newMax = (compRes == .orderedDescending) ? current - 1 : max
        
        return bsearch(min: newMin, max: newMax, comparator: comparator)
    }
    
    func binarySearch(comparator: (Iterator.Element) -> ComparisonResult) -> Iterator.Element? {
        
        return bsearch(min: 0, max: self.count - 1, comparator: comparator)
    }
}
