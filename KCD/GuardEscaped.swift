//
//  KCGuardEscaped.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

final class GuardEscaped: KCManagedObject {
    
    @NSManaged var ensured: Bool
    @NSManaged var shipID: Int
}
