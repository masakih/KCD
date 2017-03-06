//
//  KCAirBase.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/31.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

class KCAirBase: KCManagedObject {
    @NSManaged var rid: Int
    @NSManaged var name: String
    @NSManaged var area_id: Int
    @NSManaged var distance: Int
    @NSManaged var action_kind: Int
    @NSManaged var planeInfo: NSOrderedSet
}
