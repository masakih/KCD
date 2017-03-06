//
//  MapAreaTransformaer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class MapAreaTransformaer: ValueTransformer {
    override class func transformedValueClass() -> Swift.AnyClass {
        return String.self as! AnyClass
    }
    override func transformedValue(_ value: Any?) -> Any? {
        guard let v = value as? String, let areaId = Int(v) else { return nil }
        return areaId > 10 ? "E" : "\(areaId)"
    }
}
