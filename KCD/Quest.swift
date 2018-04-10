//
//  KCQuest.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/31.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
final class Quest: KCManagedObject {
    
    @NSManaged var bonus_flag: Bool
    @NSManaged var category: Int
    @NSManaged var detail: String
    @NSManaged var get_material_0: Int
    @NSManaged var get_material_1: Int
    @NSManaged var get_material_2: Int
    @NSManaged var get_material_3: Int
    @NSManaged var invalid_flag: Int
    @NSManaged var no: Int
    @NSManaged var progress_flag: Int
    @NSManaged var state: Int
    @NSManaged var title: String
    @NSManaged var type: Int
}
// swiftlint:eable identifier_name

extension Quest {
    
    @objc override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        
        switch key {
            
        case #keyPath(compositStatus): return [#keyPath(state), #keyPath(progress_flag)]
            
        default: return []
            
        }
    }
    
    @objc dynamic var compositStatus: Int {
        
        return progress_flag * 4 + state
    }
}
