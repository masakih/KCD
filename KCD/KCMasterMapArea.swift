//
//  KCMasterMapArea.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/29.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

class KCMasterMapArea: KCManagedObject {
    @NSManaged var id: Int
    @NSManaged var name: String
    @NSManaged var type: NSNumber?
}
