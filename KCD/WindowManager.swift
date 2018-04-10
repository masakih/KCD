//
//  WindowManager.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/04/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class WindowManager {
    
    private let browserWindowController = BroserWindowController()
    
    #if ENABLE_JSON_LOG
    let jsonViewWindowController: JSONViewWindowController? = {
    
        let vc = JSONViewWindowController()
        vc.showWindow(nil)
        
        return vc
    }()
    #else
    let jsonViewWindowController: JSONViewWindowController? = nil
    #endif
    
    #if UI_TEST
    private let uiTestWindowController: UITestWindowController? = {
    
        let vc = UITestWindowController()
        vc.showWindow(nil)
        
        return vc
    }()
    #else
    private let uiTestWindowController: UITestWindowController? = nil
    #endif
    
    // MARK: - Variable
    private lazy var historyWindowController: HistoryWindowController = {
        
        HistoryWindowController()
    }()
    
    private lazy var slotItemWindowController: SlotItemWindowController = {
        
        SlotItemWindowController()
    }()
    
    private lazy var preferencePanelController: PreferencePanelController = {
        
        PreferencePanelController()
    }()
    
    private lazy var upgradableShipWindowController: UpgradableShipsWindowController = {
        
        UpgradableShipsWindowController()
    }()
    
    private lazy var airBaseWindowController: AirBaseWindowController = {
        
        AirBaseWindowController()
    }()
    
    private lazy var browserContentAdjuster: BrowserContentAdjuster = {
        
        BrowserContentAdjuster()
    }()
    
    private(set) lazy var screenshotListWindowController: ScreenshotListWindowController = {
        
        let wc = ScreenshotListWindowController()
        _ = wc.window
        
        return wc
    }()
    
    private lazy var shipWindowController: ShipWindowController = {
        
        ShipWindowController()
    }()
    
    private lazy var shipMDWindowController: ShipMasterDetailWindowController = {
        
        ShipMasterDetailWindowController()
    } ()
    
    private lazy var equipmentWindowController: EquipmentWindowController = {
        
        EquipmentWindowController()
    }()
    
    private lazy var mapWindowController: MapWindowController = {
        
        MapWindowController()
    }()
    
    private var browserWindowControllers: [ExternalBrowserWindowController] = []
    private var logedJSONViewWindowController: JSONViewWindowController?
    
    var canSaveLog: Bool {
        
        return jsonViewWindowController != nil
    }
    
    var isMainWindowMostFront: Bool {
        
        guard let window = browserWindowController.window else {
            
            return false
        }
        
        return isFrontMostWindow(window)
    }
    
    func prepair() {
        
        _ = BookmarkManager.shared
        _ = screenshotListWindowController
        
        browserWindowController.showWindow(nil)
    }
    
    func createNewBrowser() -> ExternalBrowserWindowController {
        
        let browser = ExternalBrowserWindowController()
        browserWindowControllers.append(browser)
        browser.window?.makeKeyAndOrderFront(nil)
        
        NotificationCenter.default
            .addObserverOnce(forName: NSWindow.willCloseNotification, object: browser.window, queue: nil) { [unowned self] notification in
                
                if let obj = notification.object as? NSWindow,
                    let index = self.browserWindowControllers.index(where: { $0.window == obj }) {
                    
                    self.browserWindowControllers.remove(at: index)
                }
        }
        
        return browser
    }
}

// MARK: - IBActions
extension WindowManager {
    
    private func isFrontMostWindow(_ window: NSWindow) -> Bool {
        
        return window.isVisible && window.isMainWindow
    }
    
    private func makeFrontOrOrderOut(_ window: NSWindow?) {
        
        guard let window = window else {
            
            return
        }
        
        isFrontMostWindow(window) ? window.orderOut(nil) : window.makeKeyAndOrderFront(nil)
    }
    
    @IBAction func showHideHistory(_ sender: AnyObject?) {
        
        makeFrontOrOrderOut(historyWindowController.window)
    }
    
    @IBAction func showHideSlotItemWindow(_ sender: AnyObject?) {
        
        makeFrontOrOrderOut(slotItemWindowController.window)
    }
    
    @IBAction func showHideUpgradableShipWindow(_ sender: AnyObject?) {
        
        makeFrontOrOrderOut(upgradableShipWindowController.window)
    }
    
    @IBAction func showHideScreenshotListWindow(_ sender: AnyObject?) {
        
        makeFrontOrOrderOut(screenshotListWindowController.window)
    }
    
    @IBAction func showHideAirBaseInfoWindow(_ sender: AnyObject?) {
        
        makeFrontOrOrderOut(airBaseWindowController.window)
    }
    
    @IBAction func showHidePreferencePanle(_ sender: AnyObject?) {
        
        makeFrontOrOrderOut(preferencePanelController.window)
    }
    
    @IBAction func showWindowAduster(_ sender: AnyObject?) {
        
        browserContentAdjuster.showWindow(nil)
    }
    
    @IBAction func openNewBrowser(_ sender: AnyObject?) {
        
        _ = createNewBrowser()
    }
    
    @IBAction func selectBookmark(_ sender: AnyObject?) {
        
        let b = createNewBrowser()
        b.selectBookmark(sender)
    }
    
    @IBAction func showMainBrowser(_ sender: AnyObject?) {
        
        browserWindowController.showWindow(nil)
    }
    
    @IBAction func showShipWindow(_ sender: AnyObject?) {
        
        shipWindowController.showWindow(nil)
    }
    
    @IBAction func showEquipmentWindow(_ sender: AnyObject?) {
        
        equipmentWindowController.showWindow(nil)
    }
    
    @IBAction func showMapWindow(_ sender: AnyObject?) {
        
        mapWindowController.showWindow(nil)
    }
    
    @IBAction func showOwnershipShipWindow(_ sender: AnyObject?) {
        
        shipMDWindowController.showWindow(nil)
    }
    
    @IBAction func saveDocument(_ sender: AnyObject?) {
        
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["plist"]
        panel.prompt = "Save Panel"
        panel.title = "Save Panel"
        
        panel.begin {
            
            guard $0 == .OK else {
                
                return
            }
            guard let url = panel.url else {
                
                return
            }
            guard let array = self.jsonViewWindowController?.commands else {
                
                return
            }
            
            let data = NSKeyedArchiver.archivedData(withRootObject: array)
            
            do {
                
                try data.write(to: url)
                
            } catch {
                
                Logger.shared.log("Can not write to \(url)")
            }
        }
    }
    
    @IBAction func openDocument(_ sender: AnyObject?) {
        
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["plist"]
        panel.allowsMultipleSelection = false
        panel.prompt = "Open log"
        panel.title = "Open log"
        
        panel.begin {
            
            guard $0 == .OK else {
                
                return
            }
            guard let url = panel.url else {
                
                return
            }
            
            do {
                
                let data = try Data(contentsOf: url)
                let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
                guard let commands = array as? [[String: Any]] else {
                    
                    return
                }
                
                self.logedJSONViewWindowController = JSONViewWindowController()
                self.logedJSONViewWindowController?.commands = commands
                self.logedJSONViewWindowController?.window?.title = "SAVED LOG FILE VIEWER"
                self.logedJSONViewWindowController?.showWindow(nil)
                
            } catch {
                
                Logger.shared.log("Can not load \(url)")
            }
        }
    }
    
    private func setTitle(to menuItem: NSMenuItem, frontWindow window: NSWindow?, show showLabel: String, hide hideLabel: String) {
        
        guard let window = window else {
            
            return
        }
        
        if isFrontMostWindow(window) {
            
            menuItem.title = hideLabel
            
        } else {
            
            menuItem.title = showLabel
        }
    }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        
        guard let action = menuItem.action else {
            
            return false
        }
        
        switch action {
            
        case #selector(WindowManager.showHideHistory(_:)):
            
            setTitle(to: menuItem,
                     frontWindow: historyWindowController.window,
                     show: LocalizedStrings.showHistory.string,
                     hide: LocalizedStrings.hideHistory.string)
            
            return true
            
        case #selector(WindowManager.showHideSlotItemWindow(_:)):
            
            setTitle(to: menuItem,
                     frontWindow: slotItemWindowController.window,
                     show: LocalizedStrings.showSlotItem.string,
                     hide: LocalizedStrings.hideSlotItem.string)
            
            return true
            
        case #selector(WindowManager.showHideUpgradableShipWindow(_:)):
            
            setTitle(to: menuItem,
                     frontWindow: upgradableShipWindowController.window,
                     show: LocalizedStrings.showUpgradableShips.string,
                     hide: LocalizedStrings.hideUpgradableShips.string)
            
            return true
            
        case #selector(WindowManager.showHideScreenshotListWindow(_:)):
            
            setTitle(to: menuItem,
                     frontWindow: screenshotListWindowController.window,
                     show: LocalizedStrings.showScreenshotList.string,
                     hide: LocalizedStrings.hideScreenshotList.string)
            
            return true
            
        case #selector(WindowManager.showHideAirBaseInfoWindow(_:)):
            
            setTitle(to: menuItem,
                     frontWindow: airBaseWindowController.window,
                     show: LocalizedStrings.showAirbaseInfo.string,
                     hide: LocalizedStrings.hideAirbaseInfo.string)
            
            return true
            
        case #selector(WindowManager.showHidePreferencePanle(_:)):
            
            return true
            
        case #selector(WindowManager.openNewBrowser(_:)):
            
            return true
            
        case #selector(WindowManager.selectBookmark(_:)):
            
            return true
            
        case #selector(WindowManager.showWindowAduster(_:)):
            
            return true
            
        case #selector(WindowManager.showShipWindow(_:)),
             #selector(WindowManager.showEquipmentWindow(_:)),
             #selector(WindowManager.showMapWindow(_:)),
             #selector(WindowManager.showOwnershipShipWindow(_:)):
            
            return true
            
        case #selector(WindowManager.saveDocument(_:)),
             #selector(WindowManager.openDocument(_:)):
            
            return canSaveLog
            
        default:
            
            return false
        }
    }
}
