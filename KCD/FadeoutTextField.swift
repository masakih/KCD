//
//  FadeoutTextField.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/09/16.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class FadeoutTextField: NSTextField {
    
    var middle1: CGFloat = 0.8
    var middle2: CGFloat = 1.0
    
    private var maskImage: CGImage? {
        
        if !isCharacterProtrude() {
            
            return nil
        }
        
        if let image = cachMaskImage {
            
            return image
        }
        
        cachMaskImage = maskImage(middle1: middle1, middle2: middle2)
        
        return cachMaskImage
    }
    
    private var cachMaskImage: CGImage?
    
    override func draw(_ dirtyRect: NSRect) {
        
        guard let context = NSGraphicsContext.current?.cgContext else {
            
            fatalError("Con not get current CGContext")
        }
        
        context.saveGState()
        maskImage.map { context.clip(to: bounds, mask: $0) }
        
        super.draw(dirtyRect)
        
        context.restoreGState()
    }
    
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        
        cachMaskImage = nil
        
        super.resizeSubviews(withOldSize: oldSize)
    }
    
}
