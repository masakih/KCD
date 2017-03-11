//
//  KCMasterSType.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/29.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

class MasterSType: KCManagedObject {
    @NSManaged var id: Int
    @NSManaged var kcnt: NSNumber?
    @NSManaged var name: String
    @NSManaged var scnt: NSNumber?
    @NSManaged var sortno: NSNumber?
    @NSManaged var ships: Set<MasterShip>
}
