//
//  NSTextFieldExtension.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/09/16.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension NSTextField {
    
    func maskImage(middle1: CGFloat, middle2: CGFloat) -> CGImage {
        
        let colorspace = CGColorSpaceCreateDeviceGray()
        
        guard let maskContext = CGContext(data: nil,
                                          width: Int(bounds.width),
                                          height: Int(bounds.height),
                                          bitsPerComponent: 8,
                                          bytesPerRow: Int(bounds.width),
                                          space: colorspace,
                                          bitmapInfo: 0) else {
                                            
                                            fatalError("Can not create bitmap context")
        }
        
        let maskGraphicsContext = NSGraphicsContext(cgContext: maskContext, flipped: false)
        
        NSGraphicsContext.saveGraphicsState()
        defer { NSGraphicsContext.restoreGraphicsState() }
        
        NSGraphicsContext.current = maskGraphicsContext
        
        let gradient = NSGradient(colorsAndLocations: (.white, 0.0),
                                  (.white, middle1),
                                  (.black, middle2),
                                  (.black, 1.0))
        gradient?.draw(in: bounds, angle: 0.0)
        
        guard let r = maskContext.makeImage() else { fatalError(" can not create image from context") }
        
        return r
    }
    
    func isCharacterProtrude() -> Bool {
        
        guard let currentFont = font else {
            
            Swift.print("TextField dose not set font")
            
            return false
        }
        
        let string = stringValue as NSString
        let size = string.size(withAttributes: [.font: currentFont])
        
        return bounds.size.width - size.width < 3
    }
    
}
