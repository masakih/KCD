//
//  KCNyukyoDock.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/29.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
final class NyukyoDock: KCManagedObject {
    
    @NSManaged var complete_time: Int
    @NSManaged var complete_time_str: String?
    @NSManaged var id: Int
    @NSManaged var item1: NSNumber?
    @NSManaged var item2: NSNumber?
    @NSManaged var item3: NSNumber?
    @NSManaged var item4: NSNumber?
    @NSManaged var ship_id: Int
    @NSManaged var state: Int
}
