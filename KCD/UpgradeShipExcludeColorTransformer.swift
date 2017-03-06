//
//  UpgradeShipExcludeColorTransformer.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class UpgradeShipExcludeColorTransformer: ValueTransformer {
    override class func transformedValueClass() -> Swift.AnyClass {
        return NSColor.self
    }
    override func transformedValue(_ value: Any?) -> Any? {
        guard let v = value as? Int else { return nil }
        if UpgradableShipsWindowController.isExcludeShipID(v) {
            return NSColor.lightGray
        }
        return NSColor.controlTextColor
    }
}
