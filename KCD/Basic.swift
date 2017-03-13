//
//  KCBasic.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/28.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

class Basic: KCManagedObject {
    @NSManaged var active_flag: NSNumber?   // swiftlint:disable:this variable_name
    @NSManaged var comment: String?
    @NSManaged var comment_id: NSNumber?    // swiftlint:disable:this variable_name
    @NSManaged var count_deck: Int  // swiftlint:disable:this variable_name
    @NSManaged var count_kdock: Int // swiftlint:disable:this variable_name
    @NSManaged var count_ndock: Int // swiftlint:disable:this variable_name
    @NSManaged var experience: Int
    @NSManaged var fcoin: Int
    @NSManaged var firstflag: NSNumber?
    @NSManaged var fleetname: String?
    @NSManaged var furniture_0: NSNumber?   // swiftlint:disable:this variable_name
    @NSManaged var furniture_1: NSNumber?   // swiftlint:disable:this variable_name
    @NSManaged var furniture_2: NSNumber?   // swiftlint:disable:this variable_name
    @NSManaged var furniture_3: NSNumber?   // swiftlint:disable:this variable_name
    @NSManaged var furniture_4: NSNumber?   // swiftlint:disable:this variable_name
    @NSManaged var furniture_5: NSNumber?   // swiftlint:disable:this variable_name
    @NSManaged var furniture_6: NSNumber?   // swiftlint:disable:this variable_name
    @NSManaged var large_Dock: Int  // swiftlint:disable:this variable_name
    @NSManaged var level: Int
    @NSManaged var max_chara: Int   // swiftlint:disable:this variable_name
    @NSManaged var max_kagu: Int    // swiftlint:disable:this variable_name
    @NSManaged var max_slotitem: Int    // swiftlint:disable:this variable_name
    @NSManaged var medals: Int
    @NSManaged var member_id: NSNumber? // swiftlint:disable:this variable_name
    @NSManaged var ms_count: NSNumber?  // swiftlint:disable:this variable_name
    @NSManaged var ms_success: NSNumber?    // swiftlint:disable:this variable_name
    @NSManaged var nickname: String
    @NSManaged var nickname_id: NSNumber?   // swiftlint:disable:this variable_name
    @NSManaged var playtime: Int
    @NSManaged var pt_challenged: NSNumber? // swiftlint:disable:this variable_name
    @NSManaged var pt_challenged_win: NSNumber? // swiftlint:disable:this variable_name
    @NSManaged var pt_lose: NSNumber?   // swiftlint:disable:this variable_name
    @NSManaged var pt_win: NSNumber?    // swiftlint:disable:this variable_name
    @NSManaged var pvp_0: NSNumber? // swiftlint:disable:this variable_name
    @NSManaged var pvp_1: NSNumber? // swiftlint:disable:this variable_name
    @NSManaged var rank: Int
    @NSManaged var st_lose: NSNumber?   // swiftlint:disable:this variable_name
    @NSManaged var st_win: NSNumber?    // swiftlint:disable:this variable_name
    @NSManaged var starttime: Int
    @NSManaged var tutorial: NSNumber?
    @NSManaged var tutorial_progress: NSNumber? // swiftlint:disable:this variable_name
}
