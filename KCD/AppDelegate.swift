//
//  AppDelegate.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/03.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

@NSApplicationMain
final class AppDelegate: NSObject {
    
    static var shared: AppDelegate {
        
        return NSApplication.shared.delegate as! AppDelegate    // swiftlint:disable:this force_cast
    }
        
    let appNameForUserAgent: String = "KCD(1.9b36) is not Safari/604.4.7"
    private(set) var fleetManager: FleetManager?
    
    private let windowManager = WindowManager()
    
    private let historyCleanNotifer = PeriodicNotifier(hour: 0, minutes: 7)
    private let jsonTracker = JSONTracker()
    private let timeSignalNotifier = TimeSignalNotifier()
    private let resourceHistory = ResourceHistoryManager()
    
    // MARK: - Variable
    @IBOutlet private var debugMenuItem: NSMenuItem!
    
    var jsonViewWindowController: JSONViewWindowController? {
        
        return windowManager.jsonViewWindowController
    }
    
    private var updaters: [() -> Void] = []
    private var didLoadedMainMenu = false
    
    @objc dynamic var monospaceSystemFont11: NSFont {
        
        return NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
    }
    
    @objc dynamic var monospaceSystemFont12: NSFont {
        
        return NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
    }
    
    @objc dynamic var monospaceSystemFont13: NSFont {
        
        return NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    }
    
    // MARK: - Function
    override func awakeFromNib() {
        
        if didLoadedMainMenu {
            
            return
        }
        
        didLoadedMainMenu = true
        
        fleetManager = FleetManager()
        
        ValueTransformerRegister.registerAll()
        UserDefaults.standard.register(defaults: DefaultKeys.defaults)
        CustomHTTPProtocol.start()
        CommandRegister.register()
        
        windowManager.prepair()
        
        if !UserDefaults.standard[.showsDebugMenu] {
            
            debugMenuItem.isHidden = true
        }
        
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
        
        return windowManager.createNewBrowser()
    }
}

// MARK: - IBActions
extension AppDelegate {
    
    @IBAction func showHideHistory(_ sender: AnyObject?) {
        
        windowManager.showHideHistory(sender)
    }
    
    @IBAction func showHideSlotItemWindow(_ sender: AnyObject?) {
        
        windowManager.showHideSlotItemWindow(sender)
    }
    
    @IBAction func showHideUpgradableShipWindow(_ sender: AnyObject?) {
        
        windowManager.showHideUpgradableShipWindow(sender)
    }
    
    @IBAction func showHideScreenshotListWindow(_ sender: AnyObject?) {
        
        windowManager.showHideScreenshotListWindow(sender)
    }
    
    @IBAction func showHideAirBaseInfoWindow(_ sender: AnyObject?) {
        
        windowManager.showHideAirBaseInfoWindow(sender)
    }
    
    @IBAction func showHidePreferencePanle(_ sender: AnyObject?) {
        
        windowManager.showHidePreferencePanle(sender)
    }
    
    @IBAction func showWindowAduster(_ sender: AnyObject?) {
        
        windowManager.showWindowAduster(sender)
    }
    
    @IBAction func openNewBrowser(_ sender: AnyObject?) {
        
        windowManager.openNewBrowser(sender)
    }
    
    @IBAction func selectBookmark(_ sender: AnyObject?) {
        
        windowManager.selectBookmark(sender)
    }
    
    @IBAction func removeDatabaseFile(_ sender: AnyObject?) {
        
        guard let path = Bundle.main.path(forResource: "RemoveDatabaseFileAndRestart", ofType: "app") else {
            
            Logger.shared.log("Can not find RemoveDatabaseFileAndRestart.app")
            
            return
        }
        
        let process = Process()
        process.launchPath = "/usr/bin/open"
        process.arguments = [path]
        process.launch()
    }
    
    @IBAction func showMainBrowser(_ sender: AnyObject?) {
        
        windowManager.showMainBrowser(sender)
    }
    
    @IBAction func showShipWindow(_ sender: AnyObject?) {
        
        windowManager.showShipWindow(sender)
    }
    
    @IBAction func showEquipmentWindow(_ sender: AnyObject?) {
        
        windowManager.showEquipmentWindow(sender)
    }
    
    @IBAction func showMapWindow(_ sender: AnyObject?) {
        
        windowManager.showMapWindow(sender)
    }
    
    @IBAction func showOwnershipShipWindow(_ sender: AnyObject?) {
        
        windowManager.showOwnershipShipWindow(sender)
    }
    
    @IBAction func saveLocalData(_ sender: AnyObject?) {
        
        TSVSupport().save()
    }
    
    @IBAction func loadLocalData(_ sender: AnyObject?) {
        
        TSVSupport().load()
    }
    
    @IBAction func saveDocument(_ sender: AnyObject?) {
        
        windowManager.saveDocument(sender)
    }
    
    @IBAction func openDocument(_ sender: AnyObject?) {
        
        windowManager.openDocument(sender)
    }
    
    @IBAction func openInDeckBuilder(_ sender: Any?) {
        
        DeckBuilder().openDeckBuilder()
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        
        guard let action = menuItem.action else {
            
            return false
        }
        
        switch action {
            
        case #selector(AppDelegate.saveLocalData(_:)),
             #selector(AppDelegate.loadLocalData(_:)):
            
            return true
            
        case #selector(AppDelegate.removeDatabaseFile(_:)):
            
            return true
            
        case #selector(openInDeckBuilder(_:)):
            
            return true
            
        default:
            
            return windowManager.validateMenuItem(menuItem)
        }
    }
}

extension AppDelegate: NSApplicationDelegate {
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        
        if NSEvent.modifierFlags == .option {
            
            removeDatabaseFile(nil)
            
            exit(0)
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.33, repeats: true) { [weak self] _ in
            
            self?.updaters.forEach { $0() }
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        
        return true
    }
}

extension AppDelegate: NSUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        
        return true
    }
}

@available(OSX 10.12.2, *)
private var objectForTouchBar: [Int: NSTouchBar] = [:]

@available(OSX 10.12.2, *)
extension AppDelegate: NSTouchBarProvider {
    
    @IBOutlet private var mainTouchBar: NSTouchBar? {
        
        get { return objectForTouchBar[hash] }
        set { objectForTouchBar[hash] = newValue }
    }
    
    var touchBar: NSTouchBar? {
        
        get {
            
            if windowManager.isMainWindowMostFront {
                
                return nil
            }
            if let _ = mainTouchBar {
                
                return mainTouchBar
            }
            
            var topLevel: NSArray?
            Bundle.main.loadNibNamed(NSNib.Name("MainTouchBar"), owner: self, topLevelObjects: &topLevel)
            
            return mainTouchBar
        }
        set {}
    }
}
