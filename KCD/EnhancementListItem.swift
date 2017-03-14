//
//  EnhancementListItem.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/25.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

@objc
enum EquipmentType: Int {
    case unknown = -1
    
    case smallCaliberMainGun = 1
    case mediumCaliberMainGun = 2
    case largeCaliberMainGun = 3
    case secondaryGun = 4
    case torpedo = 5
    case fighter = 6
    case bomber = 7
    case attacker = 8
    case searcher = 9
    case airplaneSearcher = 10
    case airplaneBomber = 11
    case smallRadar = 12
    case largeRadar = 13
    case sonar = 14
    case depthCharge = 15
    case armorPiercingShell = 16
    case EngineImprovement = 17
    case AAShell = 18
    case APShell = 19
    case vt = 20
    case antiAircraftGun = 21
    case specialSubmarine = 22
    case damageControl = 23
    case LandingCraft = 24
    case autoGyro = 25
    case antiSunmrinerSercher = 26
    case armorPiercingShellMiddle = 27
    case armorPiercingShellLarge = 28
    case searchlight = 29
    case caryer = 30
    case repiarer = 31
    case submarinTorpedo = 32
    case chaf = 33
    case headquaters = 34
    case pilot = 35
    case antiAircraftSystem = 36
    case antiLandSystem = 37
    case largeCaliberMainGunII = 38
    case shipPersonnel = 39
    case largeSonar = 40
    case largeAirplane = 41
    case largeSearchlight = 42
    case onigiri = 43
    case supply = 44
    case airplaneFighter = 45
    case tankShip = 46
    case landAttecker = 47
    case localFighter = 48
    
    case blank01 = 49
    case blank02 = 50
    case blank03 = 51
    case blank04 = 52
    case blank05 = 53
    case blank06 = 54
    case blank07 = 55
    
    case jetFighter = 56
    case jetBomber = 57
    case jetAttacker = 58
    case jetSearcher = 59
    
    case blank08 = 60
    case blank09 = 61
    case blank10 = 62
    case blank11 = 63
    case blank12 = 64
    
    case largeLadarII = 93
    case searcherII = 94
}

class EnhancementListItem: NSObject, NSCoding, NSCopying {
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

class RequiredEquipmentSet: NSObject, NSCoding, NSCopying {
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

class RequiredEquipment: NSObject, NSCoding, NSCopying {
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
