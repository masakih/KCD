//
//  NSViewExtension.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/03.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension NSView {
    
    func setFrame(_ frame: NSRect, animate: Bool) {
        
        (animate ? self.animator() : self).frame = frame
    }
    
    func needsDisplayInMainThread() {
        
        DispatchQueue.main.async { self.needsDisplay = true }
    }
}
