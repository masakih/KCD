//
//  TimerCountFormatter.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/04.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class TimerCountFormatter: Formatter {
    
    override func string(for obj: Any?) -> String? {
        
        let v: Double? = {
            if let o = obj as? NSNumber { return o.doubleValue }
            if let o = obj as? Date { return Double(o.timeIntervalSince1970) }
            return nil
        }()
        
        guard let value = v
            else { return "" }
        
        let minus = value < 0
        var interval = minus ? -value : value
        
        let hour = Int(interval / (60 * 60))
        interval -= Double(hour * 60 * 60)
        let minutes = Int(interval / 60)
        interval -= Double(minutes * 60)
        let seconds = Int(interval)
        
        return String(format: "%@%02ld:%02ld:%02ld", arguments: [(minus ? "-" : ""), hour, minutes, seconds])
    }
}
