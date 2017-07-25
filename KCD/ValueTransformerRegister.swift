//
//  ValueTransformerRegister.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/04.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate struct Register {
    
    let prototype: ValueTransformer
    
    func register() {
        
        ValueTransformer.setValueTransformer(prototype, forName: prototype.registerName())
    }
    
    func register(name: String) {
        
        let tName = NSValueTransformerName(name)
        ValueTransformer.setValueTransformer(prototype, forName: tName)
    }
}

extension ValueTransformer {
    
    func registerName() -> NSValueTransformerName {
        
        return NSValueTransformerName(String(describing: type(of: self)))
    }
}

final class ValueTransformerRegister: NSObject {
    
    class func registerAll() {
        
        let valueTransformers: [ValueTransformer] = [
            SlotItemEquipTypeTransformer(),
            PlanToShowsBoldFontTransformer(),
            IgnoreZeroTransformer(),
            SokuTransformer(),
            LengTransformer(),
            SlotitemNameTransformer(),
            SlotItemShortNameTransformer(),
            QuestProgressTransformer(),
            MapAreaTransformaer(),
            UpgradeShipExcludeColorTransformer(),
            MillisecondTransformer(),
            DamageValueTransformer(),
            HistoryMarkTransformer(),
            OrderedSetToArrayTransformer(),
            ActinKindTransformer(),
            AirbasePlaneStateTransformer()
        ]
        valueTransformers.forEach { Register(prototype: $0).register() }
    }
}
