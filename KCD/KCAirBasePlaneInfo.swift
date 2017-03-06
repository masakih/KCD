//
//  KCAirBasePlaneInfo.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/31.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation
import CoreData

class KCAirBasePlaneInfo: KCManagedObject {
    @NSManaged var squadron_id: Int
    @NSManaged var state: Int
    @NSManaged var slotid: Int
    @NSManaged var cond: Int
    @NSManaged var count: Int
    @NSManaged var max_count: Int
    @NSManaged var airBase: KCAirBase
}
