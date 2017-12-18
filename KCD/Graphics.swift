//
//  Graphics.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/01.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

struct Polygon {
    
    private let bezierPath: NSBezierPath
    
    init() {
        
        bezierPath = NSBezierPath()
    }
    
    init(lineWidth: CGFloat) {
        
        self.init()
        bezierPath.lineWidth = lineWidth
    }
    
    init(point: NSPoint) {
        
        self.init()
        bezierPath.move(to: point)
    }
    
    private init(path: NSBezierPath) {
        
        bezierPath = path
    }
    
    var lineWidth: CGFloat {
        get { return bezierPath.lineWidth }
        set { bezierPath.lineWidth = lineWidth }
    }
    
    func line(to point: NSPoint) -> Polygon {
        
        bezierPath.line(to: point)
        
        return Polygon(path: bezierPath)
    }
    
    func move(to point: NSPoint) -> Polygon {
        
        bezierPath.move(to: point)
        
        return Polygon(path: bezierPath)
    }
    
    func close() -> Polygon {
        
        bezierPath.close()
        
        return Polygon(path: bezierPath)
    }
    
    func stroke() {
        
        bezierPath.stroke()
    }
    
    func fill() {
        
        bezierPath.fill()
    }
}
