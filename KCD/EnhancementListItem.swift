//
//  EnhancementListItem.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/25.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class EnhancementListItem: NSObject, NSCoding, NSCopying {
    
    let identifier: String
    let weekday: Int
    let equipmentType: EquipmentType
    let targetEquipment: String
    let remodelEquipment: String?
    let requiredEquipments: RequiredEquipmentSet
    let secondsShipNames: [String]
    
    init(identifier: String,
         weekday: Int,
         equipmentType: EquipmentType,
         targetEquipment: String,
         remodelEquipment: String?,
         requiredEquipments: RequiredEquipmentSet,
         secondsShipNames: [String]) {
        
        self.identifier = identifier
        self.weekday = weekday
        self.equipmentType = equipmentType
        self.targetEquipment = targetEquipment
        self.remodelEquipment = remodelEquipment
        self.requiredEquipments = requiredEquipments
        self.secondsShipNames = secondsShipNames
        
        super.init()
    }
    
    func replace(identifier: String? = nil,
                 weekday: Int? = nil,
                 equipmentType: EquipmentType? = nil,
                 targetEquipment: String? = nil,
                 remodelEquipment: String? = nil,
                 requiredEquipments: RequiredEquipmentSet? = nil,
                 secondsShipNames: [String]? = nil) -> EnhancementListItem {
        
        return EnhancementListItem(identifier: identifier ?? self.identifier,
                                     weekday: weekday ?? self.weekday,
                                     equipmentType: equipmentType ?? self.equipmentType,
                                     targetEquipment: targetEquipment ?? self.targetEquipment,
                                     remodelEquipment: remodelEquipment ?? self.remodelEquipment,
                                     requiredEquipments: requiredEquipments ?? self.requiredEquipments,
                                     secondsShipNames: secondsShipNames ?? self.secondsShipNames)
    }
    
    struct CodeKey {
        
        static let identifier = "EnhancementListItemIdentifier"
        static let weekday = "weekday"
        static let equipmentType = "equipmentType"
        static let targetEquipment = "targetEquipment"
        static let remodelEquipment = "remodelEquipment"
        static let requiredEquipments = "requiredEquipments"
        static let secondsShipNames = "secondsShipNames"
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let i = aDecoder.decodeObject(forKey: CodeKey.identifier) as? String,
            let e = EquipmentType(rawValue: aDecoder.decodeInteger(forKey: CodeKey.equipmentType)),
            let t = aDecoder.decodeObject(forKey: CodeKey.targetEquipment) as? String,
            let req = aDecoder.decodeObject(forKey: CodeKey.requiredEquipments) as? RequiredEquipmentSet,
            let s = aDecoder.decodeObject(forKey: CodeKey.secondsShipNames) as? [String]
            else { print("Can not decode EnhancementListItem"); return nil }
        
        let w = aDecoder.decodeInteger(forKey: CodeKey.weekday)
        let rem = aDecoder.decodeObject(forKey: CodeKey.remodelEquipment) as? String
        
        self.init(identifier: i,
                  weekday: w,
                  equipmentType: e,
                  targetEquipment: t,
                  remodelEquipment: rem,
                  requiredEquipments: req,
                  secondsShipNames: s)
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(identifier, forKey: CodeKey.identifier)
        aCoder.encode(weekday, forKey: CodeKey.weekday)
        aCoder.encode(equipmentType.rawValue, forKey: CodeKey.equipmentType)
        aCoder.encode(targetEquipment, forKey: CodeKey.targetEquipment)
        aCoder.encode(remodelEquipment, forKey: CodeKey.remodelEquipment)
        aCoder.encode(requiredEquipments, forKey: CodeKey.requiredEquipments)
        aCoder.encode(secondsShipNames, forKey: CodeKey.secondsShipNames)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        return EnhancementListItem(identifier: identifier,
                                   weekday: weekday,
                                   equipmentType: equipmentType,
                                   targetEquipment: targetEquipment,
                                   remodelEquipment: remodelEquipment,
                                   requiredEquipments: requiredEquipments,
                                   secondsShipNames: secondsShipNames)
    }
}

final class RequiredEquipmentSet: NSObject, NSCoding, NSCopying {
    
    let identifier: String
    let requiredEquipments: [RequiredEquipment]
    
    init(identifier: String, requiredEquipments: [RequiredEquipment]) {
        
        self.identifier = identifier
        self.requiredEquipments = requiredEquipments
        
        super.init()
    }
    
    struct CodeKey {
        
        static let identifier = "RequiredEquipmentSetIdentifier"
        static let requiredEquipments = "requiredEquipments"
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let i = aDecoder.decodeObject(forKey: CodeKey.identifier) as? String,
            let r = aDecoder.decodeObject(forKey: CodeKey.requiredEquipments) as? [RequiredEquipment]
            else { print("Can not decode RequiredEquipmentSet"); return nil }
        
        self.init(identifier: i, requiredEquipments: r)
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(identifier, forKey: CodeKey.identifier)
        aCoder.encode(requiredEquipments, forKey: CodeKey.requiredEquipments)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        return RequiredEquipmentSet(identifier: identifier,
                                    requiredEquipments: requiredEquipments)
    }
}

final class RequiredEquipment: NSObject, NSCoding, NSCopying {
    
    let identifier: String
    let currentLevelString: String
    let name: String
    let number: Int
    let screw: Int
    let ensureScrew: Int
    
    init(identifier: String, levelRange: String, name: String, number: Int, screw: Int, ensureScrew: Int) {
        
        self.identifier = identifier
        self.currentLevelString = levelRange
        self.name = name
        self.number = number
        self.screw = screw
        self.ensureScrew = ensureScrew
        
        super.init()
    }
    
    // MARK: - NSCoding, NSCopying
    struct CodeKey {
        
        static let identifier = "RequiredEquipmentIdentifier"
        static let currentLevelString = "currentLevelString"
        static let name = "name"
        static let number = "number"
        static let screw = "screw"
        static let ensureScrew = "ensureScrew"
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let i = aDecoder.decodeObject(forKey: CodeKey.identifier) as? String,
            
        let c = aDecoder.decodeObject(forKey: CodeKey.currentLevelString) as? String,
        let na = aDecoder.decodeObject(forKey: CodeKey.name) as? String
            else { print("Can not decode RequiredEquipment"); return nil }
        
        let nu = aDecoder.decodeInteger(forKey: CodeKey.number)
        let s = aDecoder.decodeInteger(forKey: CodeKey.screw)
        let e = aDecoder.decodeInteger(forKey: CodeKey.ensureScrew)
        
        self.init(identifier: i, levelRange: c, name: na, number: nu, screw: s, ensureScrew: e)
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(identifier, forKey: CodeKey.identifier)
        aCoder.encode(currentLevelString, forKey: CodeKey.currentLevelString)
        aCoder.encode(name, forKey: CodeKey.name)
        aCoder.encode(number, forKey: CodeKey.number)
        aCoder.encode(screw, forKey: CodeKey.screw)
        aCoder.encode(ensureScrew, forKey: CodeKey.ensureScrew)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        return RequiredEquipment(identifier: identifier,
                                 levelRange: currentLevelString,
                                 name: name,
                                 number: number,
                                 screw: screw,
                                 ensureScrew: ensureScrew)
    }
}

extension RequiredEquipment {
    
    dynamic var numberString: String? {
        
        if number == 0 { return nil }
        if number == -1 { return "-" }
        
        return "\(number)"
    }
}
