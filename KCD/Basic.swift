//
//  KCBasic.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/28.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
final class Basic: KCManagedObject {
    
    @NSManaged var active_flag: NSNumber?
    @NSManaged var comment: String?
    @NSManaged var count_deck: Int
    @NSManaged var count_kdock: Int
    @NSManaged var count_ndock: Int
    @NSManaged var experience: Int
    @NSManaged var fcoin: Int
    @NSManaged var firstflag: NSNumber?
    @NSManaged var fleetname: String?
    @NSManaged var furniture_0: NSNumber?
    @NSManaged var furniture_1: NSNumber?
    @NSManaged var furniture_2: NSNumber?
    @NSManaged var furniture_3: NSNumber?
    @NSManaged var furniture_4: NSNumber?
    @NSManaged var furniture_5: NSNumber?
    @NSManaged var furniture_6: NSNumber?
    @NSManaged var large_Dock: Int
    @NSManaged var level: Int
    @NSManaged var max_chara: Int
    @NSManaged var max_kagu: Int
    @NSManaged var max_slotitem: Int
    @NSManaged var medals: Int
    @NSManaged var ms_count: NSNumber?
    @NSManaged var ms_success: NSNumber?
    @NSManaged var nickname: String
    @NSManaged var playtime: Int
    @NSManaged var pt_challenged: NSNumber?
    @NSManaged var pt_challenged_win: NSNumber?
    @NSManaged var pt_lose: NSNumber?
    @NSManaged var pt_win: NSNumber?
    @NSManaged var pvp_0: NSNumber?
    @NSManaged var pvp_1: NSNumber?
    @NSManaged var rank: Int
    @NSManaged var st_lose: NSNumber?
    @NSManaged var st_win: NSNumber?
    @NSManaged var starttime: Int
    @NSManaged var tutorial: NSNumber?
    @NSManaged var tutorial_progress: NSNumber?
}
