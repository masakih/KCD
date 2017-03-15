//
//  AppDelegate.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/03.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate extension Selector {
    static let fireInAppDelegate = #selector(AppDelegate.fire(_:))
    
    static let showHideHistory = #selector(AppDelegate.showHideHistory(_:))
    static let showHideSlotItemWindow = #selector(AppDelegate.showHideSlotItemWindow(_:))
    static let showHideUpgradableShipWindow = #selector(AppDelegate.showHideUpgradableShipWindow(_:))
    static let showHideScreenshotListWindow = #selector(AppDelegate.showHideScreenshotListWindow(_:))
    static let showHideAirBaseInfoWindow = #selector(AppDelegate.showHideAirBaseInfoWindow(_:))
    static let saveLocalData = #selector(AppDelegate.saveLocalData(_:))
    static let loadLocalData = #selector(AppDelegate.loadLocalData(_:))
    static let showHidePreferencePanle = #selector(AppDelegate.showHidePreferencePanle(_:))
    static let openNewBrowser = #selector(AppDelegate.openNewBrowser(_:))
    static let selectBookmark = #selector(AppDelegate.selectBookmark(_:))
    static let showWindowAduster = #selector(AppDelegate.showWindowAduster(_:))
    
    static let saveDocument = #selector(AppDelegate.saveDocument(_:))
    static let openDocument = #selector(AppDelegate.openDocument(_:))
    static let removeDatabaseFile = #selector(AppDelegate.removeDatabaseFile(_:))
    static let showShipWindow = #selector(AppDelegate.showShipWindow(_:))
    static let showEquipmentWindow = #selector(AppDelegate.showEquipmentWindow(_:))
    static let showMapWindow = #selector(AppDelegate.showMapWindow(_:))
    static let showOwnershipShipWindow = #selector(AppDelegate.showOwnershipShipWindow(_:))
}

@NSApplicationMain
class AppDelegate: NSObject {
    static var shared: AppDelegate {
        // swiftlint:disable force_cast
        return NSApplication.shared().delegate as! AppDelegate
    }
    let appNameForUserAgent: String = "Version/9.1.2 Safari/601.7.7"
    let fleetManager: FleetManager = FleetManager()
    
    private let historyCleanNotifer = PeriodicNotifier(hour: 0, minutes: 7)
    private let jsonTracker = JSONTracker()
    private let timeSignalNotifier = TimeSignalNotifier()
    private let resourceHistory = ResourceHistoryManager()
    
    fileprivate let browserWindowController = BroserWindowController()
    
    #if ENABLE_JSON_LOG
    let jsonViewWindowController: JSONViewWindowController? = {
        let vc = JSONViewWindowController()
        vc.showWindow(nil)
        return vc
    }()
    #else
    private let jsonViewWindowController: JSONViewWindowController? = nil
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
    @IBOutlet var debugMenuItem: NSMenuItem!
    @IBOutlet var billingWindowMenuItem: NSMenuItem!
    
    fileprivate lazy var historyWindowController: HistoryWindowController = {
        HistoryWindowController()
    }()
    fileprivate lazy var slotItemWindowController: SlotItemWindowController = {
        SlotItemWindowController()
    }()
    fileprivate lazy var preferencePanelController: PreferencePanelController = {
        PreferencePanelController()
    }()
    fileprivate lazy var upgradableShipWindowController: UpgradableShipsWindowController = {
        UpgradableShipsWindowController()
    }()
    fileprivate lazy var airBaseWindowController: AirBaseWindowController = {
        AirBaseWindowController()
    }()
    fileprivate lazy var browserContentAdjuster: BrowserContentAdjuster = {
        BrowserContentAdjuster()
    }()
    fileprivate(set) lazy var screenshotListWindowController: ScreenshotListWindowController = {
        let wc = ScreenshotListWindowController()
        let _ = wc.window
        return wc
    }()
    
    fileprivate lazy var shipWindowController: ShipWindowController = {
        ShipWindowController()
    }()
    fileprivate lazy var shipMDWindowController: ShipMasterDetailWindowController = {
        ShipMasterDetailWindowController()
    } ()
    fileprivate lazy var equipmentWindowController: EquipmentWindowController = {
        EquipmentWindowController()
    }()
    fileprivate lazy var mapWindowController: MapWindowController = {
        MapWindowController()
    }()
    
    private var browserWindowControllers: [ExternalBrowserWindowController] = []
    private var updaters: [() -> Void] = []
    fileprivate var logedJSONViewWindowController: JSONViewWindowController?
    private var isLoadedMainMenu = false
    
    var screenShotSaveDirectory: String {
        get {
            return UserDefaults.standard.screenShotSaveDirectory ?? ApplicationDirecrories.pictures.path
        }
        set {
            UserDefaults.standard.screenShotSaveDirectory = newValue
        }
    }
    var screenShotSaveDirectoryURL: URL {
        return URL(fileURLWithPath: screenShotSaveDirectory)
    }
    dynamic var monospaceSystemFont11: NSFont {
        return NSFont.monospacedDigitSystemFont(ofSize: 11, weight: NSFontWeightRegular)
    }
    dynamic var monospaceSystemFont12: NSFont {
        return NSFont.monospacedDigitSystemFont(ofSize: 12, weight: NSFontWeightRegular)
    }
    dynamic var monospaceSystemFont13: NSFont {
        return NSFont.monospacedDigitSystemFont(ofSize: 13, weight: NSFontWeightRegular)
    }
    
    // MARK: - Function
    override func awakeFromNib() {
        if isLoadedMainMenu { return }
        isLoadedMainMenu = true
        
        ValueTransformerRegister.registerAll()
        UserDefaults.registerAllDefaults()
        CustomHTTPProtocol.start()
        CommandRegister.register()
        
        let _ = BookmarkManager.shared()
        let _ = screenshotListWindowController
        browserWindowController.showWindow(nil)
        if !UserDefaults.standard.showsDebugMenu { debugMenuItem.isHidden = true }
        NotificationCenter.default
        .addObserver(forName: .Periodic, object: historyCleanNotifer, queue: nil) { _ in
            HistoryItemCleaner().cleanOldHistoryItems()
        }
    }
    
    func addCounterUpdate(_ updater: @escaping () -> Void) {
        updaters.append(updater)
    }
    func clearCache() {
        CustomHTTPProtocol.clearCache()
    }
    func createNewBrowser() -> ExternalBrowserWindowController {
        let browser = ExternalBrowserWindowController()
        browserWindowControllers.append(browser)
        browser.window?.makeKeyAndOrderFront(nil)
        var token: NSObjectProtocol! = nil
        token = NotificationCenter.default
            .addObserver(forName: .NSWindowWillClose,
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
    
    func fire(_ timer: Timer) {
        updaters.forEach { $0() }
    }
}
// MARK: - IBActions
extension AppDelegate {
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
        let _ = createNewBrowser()
    }
    @IBAction func selectBookmark(_ sender: AnyObject?) {
        let b = createNewBrowser()
        b.selectBookmark(sender)
    }
    @IBAction func removeDatabaseFile(_ sender: AnyObject?) {
        guard let path = Bundle.main.path(forResource: "RemoveDatabaseFileAndRestart", ofType: "app")
            else { return print("Can not find RemoveDatabaseFileAndRestart.app") }
        let process = Process()
        process.launchPath = "/usr/bin/open"
        process.arguments = [path]
        process.launch()
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
    
    @IBAction func saveLocalData(_ sender: AnyObject?) {
        TSVSupport().save()
    }
    @IBAction func loadLocalData(_ sender: AnyObject?) {
        TSVSupport().load()
    }
    
    @IBAction func saveDocument(_ sender: AnyObject?) {
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["plist"]
        panel.prompt = "Save Panel"
        panel.title = "Save Panel"
        panel.begin {
            guard $0 == NSModalResponseOK,
                let url = panel.url,
                let array = self.jsonViewWindowController?.commands
                else { return }
            let data = NSKeyedArchiver.archivedData(withRootObject: array)
            do {
                try data.write(to: url)
            } catch { print("Can not write to \(url)") }
        }
    }
    @IBAction func openDocument(_ sender: AnyObject?) {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["plist"]
        panel.allowsMultipleSelection = false
        panel.prompt = "Open log"
        panel.title = "Open log"
        panel.begin {
            guard $0 == NSModalResponseOK,
            let url = panel.url
            else { return }
            do {
                let data = try Data(contentsOf: url)
                let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as NSData)
                guard let commands = array as? [[String: Any]]
                    else { return }
                
                self.logedJSONViewWindowController = JSONViewWindowController()
                self.logedJSONViewWindowController?.commands = commands
                self.logedJSONViewWindowController?.window?.title = "SAVED LOG FILE VIEWER"
                self.logedJSONViewWindowController?.showWindow(nil)
            } catch { print("Can not load \(url)") }
        }
    }
    
    private func setTitle(_ menuItem: NSMenuItem,
                          _ window: NSWindow?,
                          _ showLabel: String,
                          _ hideLabel: String) {
        guard let window = window else { return }
        if isFrontMostWindow(window) {
            menuItem.title = hideLabel
        } else {
            menuItem.title = showLabel
        }
    }
    // swiftlint:disable function_body_length
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let action = menuItem.action else { return false }
        switch action {
        case Selector.showHideHistory:
            setTitle(menuItem,
                     historyWindowController.window,
                     NSLocalizedString("Show History", comment: "Show History"),
                     NSLocalizedString("Hide History", comment: "Hide History"))
            return true
        case Selector.showHideSlotItemWindow:
            setTitle(menuItem,
                     slotItemWindowController.window,
                     NSLocalizedString("Show Slot Item", comment: "Show Slot Item"),
                     NSLocalizedString("Hide Slot Item", comment: "Hide Slot Item"))
            return true
        case Selector.showHideUpgradableShipWindow:
            setTitle(menuItem,
                     upgradableShipWindowController.window,
                     NSLocalizedString("Show Upgradable Ships", comment: "Show Upgradable Ships"),
                     NSLocalizedString("Hide Upgradable Ships", comment: "Hide Upgradable Ships"))
            return true
        case Selector.showHideScreenshotListWindow:
            setTitle(menuItem,
                     screenshotListWindowController.window,
                     NSLocalizedString("Show Screenshot List", comment: "Show Screenshot List"),
                     NSLocalizedString("Hide Screenshot List", comment: "Hide Screenshot List"))
            return true
        case Selector.showHideAirBaseInfoWindow:
            setTitle(menuItem,
                     airBaseWindowController.window,
                     NSLocalizedString("Show Air Base Info", comment: "Show Air Base Info"),
                     NSLocalizedString("Hide Air Base Info", comment: "Hide Air Base Info"))
            return true
        case Selector.saveLocalData, Selector.loadLocalData:
            return true
        case Selector.showHidePreferencePanle:
            return true
        case Selector.openNewBrowser:
            return true
        case Selector.selectBookmark:
            return true
        case Selector.showWindowAduster:
            return true
        case Selector.saveDocument, Selector.openDocument:
            return jsonViewWindowController != nil
        case Selector.removeDatabaseFile:
            return true
        case Selector.showShipWindow, Selector.showEquipmentWindow,
             Selector.showMapWindow, Selector.showOwnershipShipWindow:
            return true
        default:
            return false
        }
    }
}

extension AppDelegate: NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSUserNotificationCenter.default.delegate = self
        Timer.scheduledTimer(timeInterval: 0.33,
                             target: self,
                             selector: .fireInAppDelegate,
                             userInfo: nil,
                             repeats: true)
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

extension AppDelegate: NSUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}

@available(OSX 10.12.2, *)
fileprivate var objectForTouchBar: [Int: NSTouchBar] = [:]

@available(OSX 10.12.2, *)
extension AppDelegate: NSTouchBarProvider {
    @IBOutlet var mainTouchBar: NSTouchBar? {
        get {
            return objectForTouchBar[hash]
        }
        set {
            objectForTouchBar[hash] = newValue
        }
    }
    
    var touchBar: NSTouchBar? {
        get {
            let mainWindow = NSApplication.shared().mainWindow
            if mainWindow == self.browserWindowController.window { return nil }
            if let _ = mainTouchBar {
                return mainTouchBar
            }
            var topLevel: NSArray = []
            Bundle.main.loadNibNamed("MainTouchBar",
                                     owner: self,
                                     topLevelObjects: &topLevel)
            return mainTouchBar
        }
        set {}
    }
}
