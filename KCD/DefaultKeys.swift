/*
 DefaultKeys.swift
 
 Copyright (c) 2017, Hori, Masaki.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

/*
 
 DefaultKeys.swift
 
 CotEditor
 https://coteditor.com
 
 Created by 1024jp on 2017-02-14.
 
 ------------------------------------------------------------------------------
 
 © 2016-2017 1024jp
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 https://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

import Foundation
import AppKit.NSColor
import AppKit.NSControl


func rangeReguletor<T>(_ range: ClosedRange<T>) -> (T) -> T {
    
    return {
        
        let min = range.lowerBound
        let max = range.upperBound
        
        switch $0 {
            
        case let v where v < min: return min
            
        case let v where v > max: return max
            
        default: return $0
            
        }
    }
}


extension DefaultKeys {
    
    // Table sort descriptor
    static let slotItemSortDescriptors = DefaultKey<[NSSortDescriptor]>("slotItemSortKey2")
    static let shipviewSortDescriptors = DefaultKey<[NSSortDescriptor]>("shipviewsortdescriptor")
    static let powerupSupportSortDecriptors = DefaultKey<[NSSortDescriptor]>("powerupsupportsortdecriptor")
    
    // Debugging
    static let showsDebugMenu = DefaultKey<Bool>("ShowsDebugMenu")
    static let degugPrintLevel = DefaultKey<Debug.Level>("DebugPrintLevel", alternative: .none)
    
    // Main Window
    static let prevReloadDate = DefaultKey<Date>("previousReloadDate", alternative: .distantPast)
    
    // PowerUpSupport
    static let hideMaxKaryoku = DefaultKey<Bool>("hideMaxKaryoku")
    static let hideMaxLucky = DefaultKey<Bool>("hideMaxLucky")
    static let hideMaxRaisou = DefaultKey<Bool>("hideMaxRaisou")
    static let hideMaxSoukou = DefaultKey<Bool>("hideMaxSoukou")
    static let hideMaxTaiku = DefaultKey<Bool>("hideMaxTaiku")
    
    // Plan Color
    static let showsPlanColor = DefaultKey<Bool>("showsPlanColor")
    static let plan01Color = DefaultKey<NSColor>("plan01Color", alternative: #colorLiteral(red: 0.000, green: 0.043, blue: 0.518, alpha: 1))
    static let plan02Color = DefaultKey<NSColor>("plan02Color", alternative: #colorLiteral(red: 0.800, green: 0.223, blue: 0.000, alpha: 1))
    static let plan03Color = DefaultKey<NSColor>("plan03Color", alternative: #colorLiteral(red: 0.539, green: 0.012, blue: 0.046, alpha: 1))
    static let plan04Color = DefaultKey<NSColor>("plan04Color", alternative: #colorLiteral(red: 0.000, green: 0.535, blue: 0.535, alpha: 1))
    static let plan05Color = DefaultKey<NSColor>("plan05Color", alternative: #colorLiteral(red: 0.376, green: 0.035, blue: 0.535, alpha: 1))
    static let plan06Color = DefaultKey<NSColor>("plan06Color", alternative: #colorLiteral(red: 0.535, green: 0.535, blue: 0.000, alpha: 1))
    
    // Resource View
    static let minimumColoredShipCount = DefaultKey<Int>("minimumColoredShipCount", regulator: rangeReguletor(0...9))

    // Notifiy Sound
    static let playFinishMissionSound = DefaultKey<Bool>("playFinishMissionSound")
    static let playFinishNyukyoSound = DefaultKey<Bool>("playFinishNyukyoSound")
    static let playFinishKenzoSound = DefaultKey<Bool>("playFinishKenzoSound")
    
    // Upgradable List
    static let showLevelOneShipInUpgradableList = DefaultKey<Bool>("showLevelOneShipInUpgradableList")
    static let showsExcludedShipInUpgradableList = DefaultKey<Bool>("showsExcludedShipInUpgradableList")
    
    // Equipment List
    static let showEquipmentType = DefaultKey<SlotItemWindowController.ShowType>("showEquipmentType", alternative: .all)
    
    // FleetView
    static let fleetViewPosition = DefaultKey<BroserWindowController.FleetViewPosition>("fleetViewPosition", alternative: .above)
    static let fleetViewShipOrder = DefaultKey<FleetViewController.ShipOrder>("fleetViewShipOrder", alternative: .doubleLine)
    static let repairTime = DefaultKey<Date>("repairTime", alternative: .distantPast)
    
    // Combined View
    static let lastHasCombinedView = DefaultKey<Bool>("lastHasCombinedView")
    static let autoCombinedView = DefaultKey<Bool>("autoCombinedView")
    static let useSwipeChangeCombinedView = DefaultKey<Bool>("useSwipeChangeCombinedView")
    
    // Screenshos
    static let appendKanColleTag = DefaultKey<Bool>("appendKanColleTag")
    static let showsListWindowAtScreenshot = DefaultKey<Bool>("showsListWindowAtScreenshot")
    static let screenshotPreviewZoomValue = DefaultKey<Double>("screenshotPreviewZoomValue", regulator: rangeReguletor(0.2...0.99))
    static let screenshotEditorColumnCount = DefaultKey<Int>("screenshotEditorColumnCount", regulator: rangeReguletor(1...50))
    static let scrennshotEditorType = DefaultKey<Int>("scrennshotEditorType")
    static let screenshotButtonSize = DefaultKey<NSControl.ControlSize>("screenshotButtonSize", alternative: .regular)
    static let useMask = DefaultKey<Bool>("useMask")
    static let screenShotBorderWidth = DefaultKey<CGFloat>("screenShotBorderWidth", regulator: rangeReguletor(0.0...20.0))
    static let screenShotSaveDirectory = DefaultKey<String?>("screenShotSaveDirectory")
    
    // Old History Item Clean
    static let cleanOldHistoryItems = DefaultKey<Bool>("cleanOldHistoryItems")
    static let cleanSinceDays = DefaultKey<Int>("cleanSiceDays", regulator: rangeReguletor(1...Int.max))
    
    // Notify time signal
    static let notifyTimeSignal = DefaultKey<Bool>("notifyTimeSignal")
    static let notifyTimeBeforeTimeSignal = DefaultKey<Int>("notifyTimeBeforeTimeSignal", regulator: rangeReguletor(1...59))
    static let playNotifyTimeSignalSound = DefaultKey<Bool>("playNotifyTimeSignalSound")
    
    // Sakuteki Calculate
    static let sakutekiCalclationSterategy = DefaultKey<FleetViewController.SakutekiCalclationSterategy>("sakutekiCalclationSterategy", alternative: .total)
    static let formula33Factor = DefaultKey<Double>("formula33Factor")
    
}
