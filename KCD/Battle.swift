//
//  KCBattle.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

class Battle: KCManagedObject {
    
    @NSManaged var battleCell: NSNumber?
    @NSManaged var deckId: Int
    @NSManaged var isBossCell: Bool
    @NSManaged var mapArea: Int
    @NSManaged var mapInfo: Int
    @NSManaged var no: Int
    @NSManaged var firstFleetShipsCount: Int
    @NSManaged var damages: NSOrderedSet
}
