//
//  KCQuest.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/31.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

class Quest: KCManagedObject {
    @NSManaged var bonus_flag: Bool // swiftlint:disable:this variable_name
    @NSManaged var category: Int
    @NSManaged var detail: String
    @NSManaged var get_material_0: Int  // swiftlint:disable:this variable_name
    @NSManaged var get_material_1: Int  // swiftlint:disable:this variable_name
    @NSManaged var get_material_2: Int  // swiftlint:disable:this variable_name
    @NSManaged var get_material_3: Int  // swiftlint:disable:this variable_name
    @NSManaged var invalid_flag: Int    // swiftlint:disable:this variable_name
    @NSManaged var no: Int
    @NSManaged var progress_flag: Int   // swiftlint:disable:this variable_name
    @NSManaged var state: Int
    @NSManaged var title: String
    @NSManaged var type: Int
}

extension Quest {
    class func keyPathsForValuesAffectingCompositStatus() -> Set<String> {
        return ["state", "progress_flag"]
    }
    dynamic var compositStatus: Int {
        return progress_flag * 4 + state
    }
}
