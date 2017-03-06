//
//  KCDamage.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

class KCDamage: KCManagedObject {
    @NSManaged var id: Int
    @NSManaged var battle: KCBattle
    @NSManaged var hp: Int
    @NSManaged var shipID: Int
    @NSManaged var useDamageControl: Bool
}
