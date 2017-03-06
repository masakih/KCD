//
//  MillisecondTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class MillisecondTransformer: ValueTransformer {
    override class func transformedValueClass() -> Swift.AnyClass {
        return Double.self as! AnyClass
    }
    override func transformedValue(_ value: Any?) -> Any? {
        guard let v = value as? Double else { return nil }
        return v / 1_000.0
    }
}
