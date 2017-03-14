//
//  KCKenzoDock.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/29.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

// swiftlint:disable variable_name
class KenzoDock: KCManagedObject {
    @NSManaged var complete_time: Int
    @NSManaged var complete_time_str: String?
    @NSManaged var created_ship_id: Int
    @NSManaged var id: Int
    @NSManaged var item1: Int
    @NSManaged var item2: Int
    @NSManaged var item3: Int
    @NSManaged var item4: Int
    @NSManaged var item5: Int
    @NSManaged var member_id: NSNumber?
    @NSManaged var state: Int
}
