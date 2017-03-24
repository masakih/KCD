//
//  AreaNameTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class AreaNameTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    override func transformedValue(_ value: Any?) -> Any? {
        guard let id = value as? Int else { return nil }
        return ServerDataStore.default.mapArea(byId: id)?.name
    }
}
