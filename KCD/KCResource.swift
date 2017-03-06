//
//  KCResource.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/28.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class KCResource: NSManagedObject {
    @NSManaged var steel: Int
    @NSManaged var fuel: Int
    @NSManaged var bull: Int
    @NSManaged var bauxite: Int
    @NSManaged var kaihatusizai: Int
    @NSManaged var kousokukenzo: Int
    @NSManaged var kousokushuhuku: Int
    @NSManaged var screw: Int
    @NSManaged var experience: Int
    @NSManaged var date: Date
    @NSManaged var minute: Int
}
