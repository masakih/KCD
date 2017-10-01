//
//  WindowManager.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/04/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

private extension Selector {
    
    static let showHideHistory = #selector(WindowManager.showHideHistory(_:))
    static let showHideSlotItemWindow = #selector(WindowManager.showHideSlotItemWindow(_:))
    static let showHideUpgradableShipWindow = #selector(WindowManager.showHideUpgradableShipWindow(_:))
    static let showHideScreenshotListWindow = #selector(WindowManager.showHideScreenshotListWindow(_:))
    static let showHideAirBaseInfoWindow = #selector(WindowManager.showHideAirBaseInfoWindow(_:))
    static let showHidePreferencePanle = #selector(WindowManager.showHidePreferencePanle(_:))
    static let openNewBrowser = #selector(WindowManager.openNewBrowser(_:))
    static let selectBookmark = #selector(WindowManager.selectBookmark(_:))
    static let showWindowAduster = #selector(WindowManager.showWindowAduster(_:))
    
    static let showShipWindow = #selector(WindowManager.showShipWindow(_:))
    static let showEquipmentWindow = #selector(WindowManager.showEquipmentWindow(_:))
    static let showMapWindow = #selector(WindowManager.showMapWindow(_:))
    static let showOwnershipShipWindow = #selector(WindowManager.showOwnershipShipWindow(_:))
    
    static let saveDocument = #selector(WindowManager.saveDocument(_:))
    static let openDocument = #selector(WindowManager.openDocument(_:))
}

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
    private var updaters: [() -> Void] = []
    private var logedJSONViewWindowController: JSONViewWindowController?
    
    var canSaveLog: Bool {
        
        return jsonViewWindowController != nil
    }
    
    var isMainWindowMostFront: Bool {
        
        guard let window = browserWindowController.window else { return false }
        
        return isFrontMostWindow(window)
    }
    
    func prepair() {
        
        _ = BookmarkManager.shared()
        _ = screenshotListWindowController
        
        browserWindowController.showWindow(nil)
    }
    
    func createNewBrowser() -> ExternalBrowserWindowController {
        
        let browser = ExternalBrowserWindowController()
        browserWindowControllers.append(browser)
        browser.window?.makeKeyAndOrderFront(nil)
        
        var token: NSObjectProtocol! = nil
        
        token = NotificationCenter.default
            .addObserver(forName: NSWindow.willCloseNotification,
                         object: browser.window,
                         queue: nil) { [unowned self] notification in
                            
                            NotificationCenter.default.removeObserver(token)
                            if let obj = notification.object as? NSWindow,
                                let index = self.browserWindowControllers.index(where: { $0.window == obj }) {
                                
                                self.browserWindowControllers.remove(at: index)
                            }
        }
        
        return browser
    }
    
    func registerScreenshot(_ image: NSBitmapImageRep, fromOnScreen: NSRect) {
        
        screenshotListWindowController.registerScreenshot(image, fromOnScreen: fromOnScreen)
    }
}

// MARK: - IBActions
extension WindowManager {
    
    private func isFrontMostWindow(_ window: NSWindow) -> Bool {
        
        return window.isVisible && window.isMainWindow
    }
    
    private func makeFrontOrOrderOut(_ window: NSWindow?) {
        
        guard let window = window else { return }
        
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
            
            guard $0 == .OK else { return }
            guard let url = panel.url else { return }
            guard let array = self.jsonViewWindowController?.commands else { return }
            
            let data = NSKeyedArchiver.archivedData(withRootObject: array)
            
            do {
                
                try data.write(to: url)
                
            } catch {
                print("Can not write to \(url)")
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
            
            guard $0 == .OK else { return }
            guard let url = panel.url else { return }
            
            do {
                
                let data = try Data(contentsOf: url)
                let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
                guard let commands = array as? [[String: Any]] else { return }
                
                self.logedJSONViewWindowController = JSONViewWindowController()
                self.logedJSONViewWindowController?.commands = commands
                self.logedJSONViewWindowController?.window?.title = "SAVED LOG FILE VIEWER"
                self.logedJSONViewWindowController?.showWindow(nil)
                
            } catch {
                
                print("Can not load \(url)")
            }
        }
    }
    
    private func setTitle(_ menuItem: NSMenuItem, _ window: NSWindow?, _ showLabel: String, _ hideLabel: String) {
        
        guard let window = window else { return }
        
        if isFrontMostWindow(window) {
            
            menuItem.title = hideLabel
            
        } else {
            
            menuItem.title = showLabel
        }
    }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        
        guard let action = menuItem.action else { return false }
        
        switch action {
        case Selector.showHideHistory:
            setTitle(menuItem,
                     historyWindowController.window,
                     LocalizedStrings.showHistory.string,
                     LocalizedStrings.hideHistory.string)
            return true
            
        case Selector.showHideSlotItemWindow:
            setTitle(menuItem,
                     slotItemWindowController.window,
                     LocalizedStrings.showSlotItem.string,
                     LocalizedStrings.hideSlotItem.string)
            return true
            
        case Selector.showHideUpgradableShipWindow:
            setTitle(menuItem,
                     upgradableShipWindowController.window,
                     LocalizedStrings.showUpgradableShips.string,
                     LocalizedStrings.hideUpgradableShips.string)
            return true
            
        case Selector.showHideScreenshotListWindow:
            setTitle(menuItem,
                     screenshotListWindowController.window,
                     LocalizedStrings.showScreenshotList.string,
                     LocalizedStrings.hideScreenshotList.string)
            return true
            
        case Selector.showHideAirBaseInfoWindow:
            setTitle(menuItem,
                     airBaseWindowController.window,
                     LocalizedStrings.showAirbaseInfo.string,
                     LocalizedStrings.hideAirbaseInfo.string)
            return true
            
        case Selector.showHidePreferencePanle:
            return true
            
        case Selector.openNewBrowser:
            return true
            
        case Selector.selectBookmark:
            return true
            
        case Selector.showWindowAduster:
            return true
            
        case Selector.showShipWindow, Selector.showEquipmentWindow,
             Selector.showMapWindow, Selector.showOwnershipShipWindow:
            return true
            
        case Selector.saveDocument, Selector.openDocument:
            return canSaveLog
            
        default:
            return false
        }
    }
}
