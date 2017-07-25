//
//  HiddenDropShipHistory.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/03/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import CoreData

final class HiddenDropShipHistory: NSManagedObject {
    
    @NSManaged var shipName: String
    @NSManaged var mapArea: String
    @NSManaged var mapInfo: Int
    @NSManaged var mapCell: Int
    @NSManaged var mapAreaName: String
    @NSManaged var mapInfoName: String
    @NSManaged var date: Date
    @NSManaged var winRank: String
}
