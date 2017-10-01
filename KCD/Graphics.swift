//
//  Graphics.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/01.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension NSBezierPath {
    
    convenience init(start point: NSPoint) {
        
        self.init()
        move(to: point)
    }
}

func polygon(_ point: () -> [NSPoint]) -> NSBezierPath? {
    
    return polygon(points: point())
}

func polygon(points: [NSPoint]) -> NSBezierPath? {
    
    guard points.count > 2 else { return nil }
    
    let path = polyline(points: points)
    path?.close()
    
    return path
}

func polyline(_ point: () -> [NSPoint]) -> NSBezierPath? {
    
    return polyline(points: point())
}

func polyline(points: [NSPoint]) -> NSBezierPath? {
    
    guard points.count > 1 else { return nil }
    
    return points.dropFirst().reduce(NSBezierPath(start: points[0]), lineToPoint)
}

func lineToPoint(path: NSBezierPath, point: NSPoint) -> NSBezierPath {
    
    path.line(to: point)
    return path
}

func multiline(_ lines: () -> [(NSPoint, NSPoint)]) -> NSBezierPath {
    
    return multiline(lines: lines())
}

func multiline(lines: [(NSPoint, NSPoint)]) -> NSBezierPath {
    
    return lines.reduce(NSBezierPath(), line)
}

func line(_ path: NSBezierPath, _ points: (NSPoint, NSPoint)) -> NSBezierPath {
    
    path.move(to: points.0)
    path.line(to: points.1)
    return path
}
