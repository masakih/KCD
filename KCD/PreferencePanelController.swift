//
//  PreferencePanelController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/19.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

enum PreferencesPaneType: Int {
    
    case general = 1
    
    case notification = 2
}

enum ScreenshotSaveDirectoryPopupMenuItemTag: Int {
    
    case saveDirectory = 1000
    
    case selectDiretory = 2000
}

private extension Selector {
    
    static let didChangeSelection = #selector(PreferencePanelController.didChangeSelection(_:))
}

final class PreferencePanelController: NSWindowController {
    
    @IBOutlet private var screenShotSaveDirectoryPopUp: NSPopUpButton!
    @IBOutlet private var generalPane: NSView!
    @IBOutlet private var notificationPane: NSView!
    
    override var windowNibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    private(set) var screenShotSaveDirectory: String {
        
        get { return ApplicationDirecrories.shared.screenShotSaveDirectory }
        set {
            
            ApplicationDirecrories.shared.setScreenshotDirectory(newValue)
            
            let index = screenShotSaveDirectoryPopUp
                .indexOfItem(withTag: ScreenshotSaveDirectoryPopupMenuItemTag.saveDirectory.rawValue)
            
            guard let item = screenShotSaveDirectoryPopUp.item(at: index) else {
                
                return
            }
            
            let icon = NSWorkspace.shared.icon(forFile: newValue)
            let iconSize = icon.size
            let height: Double = 16
            icon.size = NSSize(width: Double(iconSize.width) * height / Double(iconSize.height), height: height)
            
            item.image = icon
            item.title = FileManager.default.displayName(atPath: newValue)
        }
    }
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        screenShotSaveDirectory = ApplicationDirecrories.shared.screenShotSaveDirectory
        
        guard let window = window else {
            
            return
        }
        guard let item = window.toolbar?.items.first else {
            
            return
        }
        
        window.toolbar?.selectedItemIdentifier = item.itemIdentifier
        NSApplication.shared.sendAction(.didChangeSelection, to: self, from: item)
        
        window.center()
    }
    
    @IBAction func selectScreenShotSaveDirectoryPopUp(_ sender: AnyObject?) {
        
        guard let window = window else {
            
            return
        }
        guard let tag = sender?.tag else {
            
            return
        }
        guard let itemTag = ScreenshotSaveDirectoryPopupMenuItemTag(rawValue: tag) else {
            
            return
        }
        guard itemTag == .selectDiretory else {
            
            return
        }
        
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.beginSheetModal(for: window) {
            
            self.screenShotSaveDirectoryPopUp
                .selectItem(withTag: ScreenshotSaveDirectoryPopupMenuItemTag.saveDirectory.rawValue)
            
            guard $0 != .cancel else {
                
                return
            }
            guard let path = panel.url?.path else {
                
                return
            }
            
            self.screenShotSaveDirectory = path
        }
    }
    
    @IBAction func didChangeSelection(_ sender: AnyObject?) {
        
        guard let tag = sender?.tag else {
            
            return
        }
        guard let paneType = PreferencesPaneType(rawValue: tag) else {
            
            return
        }
        
        let pane: NSView
        switch paneType {
            
        case .general: pane = generalPane
            
        case .notification: pane = notificationPane
            
        }

        guard let item = sender as? NSToolbarItem else {
            
            return
        }
        guard let window = self.window else {
            
            return
        }
        
        window.title = item.label
        window.contentView?.subviews.forEach { $0.removeFromSuperview() }
        
        let windowRect = window.frame
        var newWindowRect = window.frameRect(forContentRect: pane.frame)
        newWindowRect.origin.x = windowRect.origin.x
        newWindowRect.origin.y = windowRect.origin.y + windowRect.size.height - newWindowRect.size.height
        window.setFrame(newWindowRect, display: true, animate: true)
        window.contentView?.addSubview(pane)
    }
}
