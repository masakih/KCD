//
//  LocalizedStrings.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/10/01.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

struct LocalizedStrings {}

/// WindowManager
extension LocalizedStrings {
    
    /// Menu itmes
    static let showHistory = LocalizedString("Show History", comment: "Show History")
    static let hideHistory = LocalizedString("Hide History", comment: "Hide History")
    static let showSlotItem = LocalizedString("Show Slot Item", comment: "Show Slot Item")
    static let hideSlotItem = LocalizedString("Hide Slot Item", comment: "Hide Slot Item")
    static let showUpgradableShips = LocalizedString("Show Upgradable Ships", comment: "Show Upgradable Ships")
    static let hideUpgradableShips = LocalizedString("Hide Upgradable Ships", comment: "Hide Upgradable Ships")
    static let showScreenshotList = LocalizedString("Show Screenshot List", comment: "Show Screenshot List")
    static let hideScreenshotList = LocalizedString("Hide Screenshot List", comment: "Hide Screenshot List")
    static let showAirbaseInfo = LocalizedString("Show Air Base Info", comment: "Show Air Base Info")
    static let hideAirbaseInfo = LocalizedString("Hide Air Base Info", comment: "Hide Air Base Info")
    
}

/// SokuTransformer
extension LocalizedStrings {
    
    static let slow = LocalizedString("Slow", comment: "Speed, slow")
    static let fast = LocalizedString("Fast", comment: "Speed, fast")
    static let faster = LocalizedString("Faster", comment: "Speed, faster")
    static let fastest = LocalizedString("Fastest", comment: "Speed, fastest")
    
}

/// LengTransformer
extension LocalizedStrings {
    
    static let short = LocalizedString("Short", comment: "Range, short")
    static let middle = LocalizedString("Middle", comment: "Range, middle")
    static let long = LocalizedString("Long", comment: "Range, long")
    static let overLong = LocalizedString("Very Long", comment: "Range, very long")
    
}

/// ActinKindTransformer
extension LocalizedStrings {
    
    static let standBy = LocalizedString("StandBy", comment: "Airbase action kind")
    static let sortie = LocalizedString("Sortie", comment: "Airbase action kind")
    static let airDifense = LocalizedString("Air Difence", comment: "Airbase action kind")
    static let shelter = LocalizedString("Shelter", comment: "Airbase action kind")
    static let rest = LocalizedString("Rest", comment: "Airbase action kind")
    
}

/// AirbasePlaneStateTransformer
extension LocalizedStrings {
    
    static let rotating = LocalizedString("rotating", comment: "AirbasePlaneStateTransformer")
}

/// MissionStatus
extension LocalizedStrings {
    
    static let missionWillReturnMessage = LocalizedString("%@ Will Return From Mission.", comment: "%@ Will Return From Mission.")
    static let missionWillReturnInformation = LocalizedString("%@ Will Return From %@.", comment: "%@ Will Return From %@.")
    
}

/// NyukyoDockStatus
extension LocalizedStrings {
    
    static let dockingWillFinish = LocalizedString("%@ Will Finish Docking.", comment: "%@ Will Finish Docking.")
    
}

/// KenzoDockStatus
extension LocalizedStrings {
    
    static let buildingWillFinish = LocalizedString("It Will Finish Build at No.%@.", comment: "It Will Finish Build at No.%@.")
    
}

/// TimeSignalNotifier
extension LocalizedStrings {
    
    static let timerSIgnalMessage = LocalizedString("It is soon %zd o'clock.", comment: "It is soon %zd o'clock.")
    
}

/// StoreCreateSlotItemHistoryCommand
extension LocalizedStrings {
    
    static let failDevelop = LocalizedString("fail to develop", comment: "fail to develop")
    
}

/// BridgeViewController
extension LocalizedStrings {
    
    static let tweetTag = LocalizedString("kancolle", comment: "kancolle twitter hash tag")
    
}

/// BroserWindowController
extension LocalizedStrings {
    
    /// Menu items
    static let showCombinedView = LocalizedString("Show Combined View", comment: "View menu, show combined view")
    static let hideCombinedView = LocalizedString("Hide Combined View", comment: "View menu, hide combined view")
    
}

/// GameViewController
extension LocalizedStrings {
    
    /// Menu items
    static let reload = LocalizedString("Reload", comment: "Reload menu, reload")
    static let backToGame = LocalizedString("Back To Game", comment: "Reload menu, back to game")
    
    /// Others
    static let reloadTimeShortenMessage = LocalizedString("Reload interval is too short?", comment: "")
    static let reloadTimeShortenInfo = LocalizedString("Reload interval is too short.\nWait until %@.", comment: "")
    static let deletingCacheInfo = LocalizedString("Deleting caches...", comment: "Deleting caches...")
}

/// DocksViewController
extension LocalizedStrings {
    
    static let sortieInfomation = LocalizedString("%@ in sortie into %@ (%@)", comment: "Sortie")
    static let battleWithBOSS = LocalizedString("%@ battle against the enemy main fleet at %@ war zone in %@ (%@) now", comment: "Sortie")
    static let battleInformation = LocalizedString("%@ battle at %@ war zone in %@ (%@) now", comment: "Sortie")
}

/// HistoryTableViewController
extension LocalizedStrings {
    
    static let addMark = LocalizedString("Add mark", comment: "Add history mark.")
    static let removeMark = LocalizedString("Remove mark", comment: "Remove history mark.")
    
}

/// SlotItemWindowController
extension LocalizedStrings {
    
    static let allEquipment = LocalizedString("All", comment: "show equipment type All")
    static let equiped = LocalizedString("Equiped", comment: "show equipment type Equiped")
    static let unequiped = LocalizedString("Unequiped", comment: "show equipment type Unequiped")
    
}

/// UpgradableShipsWindowController
extension LocalizedStrings {
    
    static let showKanmusu = LocalizedString("Show Kanmusu", comment: "UpgradableShipsWindowController menu item")
    static let hideKanmusu = LocalizedString("Hide Kanmusu", comment: "UpgradableShipsWindowController menu item")
    
}

/// ExternalBrowserWindowController
extension LocalizedStrings {
    
    /// Menu Items
    static let showBookmark = LocalizedString("Show Bookmark", comment: "Menu item title, Show Bookmark")
    static let hideBookmark = LocalizedString("Hide Bookmark", comment: "Menu item title, Hide Bookmark")
    
}

/// CombineTypeName
extension LocalizedStrings {
    
    static let uncombined = LocalizedString("Normal Force", comment: "CombineTypeName")
    static let maneuver = LocalizedString("The Carrier Task Force", comment: "CombineTypeName")
    static let water = LocalizedString("The Surface Task Force", comment: "CombineTypeName")
    static let transportation = LocalizedString("Transport Escort", comment: "CombineTypeName")
    
}
