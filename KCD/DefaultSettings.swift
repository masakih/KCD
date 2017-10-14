/*
 DefaultSettings.swift
 
 Copyright (c) 2017, Hori, Masaki.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

/*
 
 DefaultSettings.swift
 
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


enum DefaultsKeyError: Error {
    case canNotStoreType
}


protocol DefaultValuePrimitive { }
extension Bool: DefaultValuePrimitive { }
extension Int: DefaultValuePrimitive { }
extension UInt: DefaultValuePrimitive { }
extension Float: DefaultValuePrimitive { }
extension Double: DefaultValuePrimitive { }
extension CGFloat: DefaultValuePrimitive { }
extension Data: DefaultValuePrimitive { }
extension String: DefaultValuePrimitive { }
extension URL: DefaultValuePrimitive { }
extension Array: DefaultValuePrimitive { }
extension Dictionary: DefaultValuePrimitive { }


// FIXME: value [["key": Date()]] returns true but it can not into UserDefaults.
func isDefaultValuePrimitive(_ value: Any) -> Bool {
    
    if value is [Any] {
        
        switch value {
        case _ as [DefaultValuePrimitive]: return true
        default: return false
        }
    }
    
    if value is [AnyHashable: Any] {
        
        switch value {
        case _ as [String: DefaultValuePrimitive]: return true
        default: return false
        }
    }
    
    if value is DefaultValuePrimitive {
        
        return true
    }
    
    return false
}

// FIXME: value [["key": <Any Struct>]] returns true but it can not KeyedUnarchive.
func canCoding(_ value: Any) -> Bool {
    
    if value is [Any] {
        
        switch value {
        case _ as [NSCoding]: return true
        default: return false
        }
    }
    
    if value is [AnyHashable: Any] {
        
        switch value {
        case _ as [String: NSCoding]: return true
        default: return false
        }
    }
    
    if value is NSCoding {
        
        return true
    }
    
    return false
}

extension DefaultKeys {
    
    static let settings: [DefaultKeys: Any?] = [
        
        .slotItemSortDescriptors: nil,
        .shipviewSortDescriptors: nil,
        .powerupSupportSortDecriptors: nil,
        
        .showsDebugMenu: false,
        .degugPrintLevel: nil,
        
        .prevReloadDate: nil,
        
        .hideMaxKaryoku: false,
        .hideMaxLucky: false,
        .hideMaxRaisou: false,
        .hideMaxSoukou: false,
        .hideMaxTaiku: false,
        
        .showsPlanColor: true,
        .plan01Color: #colorLiteral(red: 0.000, green: 0.043, blue: 0.518, alpha: 1),
        .plan02Color: #colorLiteral(red: 0.800, green: 0.223, blue: 0.000, alpha: 1),
        .plan03Color: #colorLiteral(red: 0.539, green: 0.012, blue: 0.046, alpha: 1),
        .plan04Color: #colorLiteral(red: 0.000, green: 0.535, blue: 0.535, alpha: 1),
        .plan05Color: #colorLiteral(red: 0.376, green: 0.035, blue: 0.535, alpha: 1),
        .plan06Color: #colorLiteral(red: 0.535, green: 0.535, blue: 0.000, alpha: 1),
        
        .minimumColoredShipCount: 0,
        
        .playFinishMissionSound: true,
        .playFinishNyukyoSound: true,
        .playFinishKenzoSound: true,
        
        .showLevelOneShipInUpgradableList: true,
        .showsExcludedShipInUpgradableList: true,
        
        .showEquipmentType: nil,
        
        .fleetViewPosition: nil,
        .fleetViewShipOrder: nil,
        .repairTime: nil,
        
        .lastHasCombinedView: false,
        .autoCombinedView: true,
        .useSwipeChangeCombinedView: false,
        
        .appendKanColleTag: true,
        .showsListWindowAtScreenshot: false,
        .screenshotPreviewZoomValue: 0.4,
        .screenshotEditorColumnCount: 2,
        .scrennshotEditorType: nil,
        .screenshotButtonSize: nil,
        .useMask: false,
        .screenShotBorderWidth: 0.0,
        .screenShotSaveDirectory: nil,
        
        .cleanOldHistoryItems: false,
        .cleanSinceDays: 90,
        
        .notifyTimeSignal: false,
        .notifyTimeBeforeTimeSignal: 5,
        .playNotifyTimeSignalSound: false,
        
        .sakutekiCalclationSterategy: nil,
        .formula33Factor: 1.0
        
    ]
    
    static let defaults: [String: Any] = settings
        .flatMap { (k: DefaultKeys, v: Any?) -> (key: String, value: Any)? in
            
            guard let value = v else { return nil }
            
            if isDefaultValuePrimitive(value) {
                
                return (key: k.rawValue, value: value)
            }
            
            if canCoding(value) {
                
                return (key: k.rawValue, value: NSKeyedArchiver.archivedData(withRootObject: value))
            }
            
            print("DefaultKeys can not store this type", type(of: value))
            
            return nil
        }
        .reduce(into: [String: Any]()) { (dict: inout [String: Any], pair) in
            dict[pair.key] = pair.value
    }
    
}
