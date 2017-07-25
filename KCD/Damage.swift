//
//  KCDamage.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

final class Damage: KCManagedObject {
    
    @NSManaged var id: Int
    @NSManaged var battle: Battle
    @NSManaged var hp: Int
    @NSManaged var shipID: Int
    @NSManaged var useDamageControl: Bool
}
