//
//  Graphics.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/01.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

func polygon(_ point: () -> [NSPoint]) -> NSBezierPath? {
    let points = point()
    let count = points.count
    guard count > 2 else { return nil }
    let path = NSBezierPath()
    path.move(to: points[0])
    points[1..<count].forEach { path.line(to: $0) }
    path.close()
    
    return path
}
func polyline(_ point: () -> [NSPoint]) -> NSBezierPath? {
    let points = point()
    let count = points.count
    guard count > 1 else { return nil }
    let path = NSBezierPath()
    path.move(to: points[0])
    points[1..<count].forEach { path.line(to: $0) }
    
    return path
}
func multiline(_ lines: () -> [(NSPoint, NSPoint)]) -> NSBezierPath? {
    let path = NSBezierPath()
    lines().forEach {
        path.move(to: $0.0)
        path.line(to: $0.1)
    }
    return path
}
