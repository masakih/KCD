//
//  GameViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/31.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa
import WebKit
import JavaScriptCore

fileprivate extension Selector {
    
    static let reloadContent = #selector(GameViewController.reloadContent(_:))
    static let deleteCacheAndReload = #selector(GameViewController.deleteCacheAndReload(_:))
    static let screenShot = #selector(GameViewController.screenShot(_:))
}

final class GameViewController: NSViewController {
    
    private static let gamePageURL = "http://www.dmm.com/netgame/social/-/gadgets/=/app_id=854854/"
    private static let loginPageURLPrefix = "https://www.dmm.com/my/-/login/=/"
    
    @IBOutlet var webView: WebView!
    
    override var nibName: String! {
        
        return "GameViewController"
    }
    
    fileprivate var flashTopLeft = NSPoint(x: 2600, y: 1445)
    private var clipView: NSClipView {
        
        return view as! NSClipView  // swiftlint:disable:this force_cast
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        clipView.documentView = webView
        
        adjustFlash()
        
        webView.mainFrame.frameView.allowsScrolling = false
        
        webView.applicationNameForUserAgent = AppDelegate.shared.appNameForUserAgent
        webView.mainFrameURL = GameViewController.gamePageURL
    }
    
    func adjustFlash() {
        
        webView.superview?.scroll(flashTopLeft)
    }
    
    @IBAction func reloadContent(_ sender: AnyObject?) {
        
        guard let _ = webView.mainFrameURL
            else {
                webView.mainFrameURL = GameViewController.gamePageURL
                return
        }
        
        // ゲームページでない場合はゲームページを表示する
        if webView.mainFrameURL != GameViewController.gamePageURL {
            
            webView.mainFrameURL = GameViewController.gamePageURL
            
            return
        }
        if webView.mainFrameURL.hasPrefix(GameViewController.loginPageURLPrefix) {
            
            webView.reload(sender)
            
            return
        }
        
        adjustFlash()
        
        let prevDate = UserDefaults.standard[.prevReloadDate]
        if Date(timeIntervalSinceNow: 0.0).timeIntervalSince(prevDate) < 1 * 60 {
            
            let untilDate = prevDate.addingTimeInterval(1 * 60)
            let date = DateFormatter.localizedString(from: untilDate, dateStyle: .none, timeStyle: .medium)
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("Reload interval is too short?", comment: "")
            let format = NSLocalizedString("Reload interval is too short.\nWait until %@.", comment: "")
            alert.informativeText = String(format: format, date)
            alert.runModal()
            
            return
        }
        
        webView.reload(sender)
        
        UserDefaults.standard[.prevReloadDate] = Date(timeIntervalSinceNow: 0.0)
    }
    
    @IBAction func deleteCacheAndReload(_ sender: AnyObject?) {
        
        let panel = ProgressPanel()
        
        guard let window = view.window,
            let panelWindow = panel.window
            else { return }
        
        panel.title = ""
        panel.message = NSLocalizedString("Deleting caches...", comment: "Deleting caches...")
        panel.animate = true
        
        window.beginSheet(panelWindow) { _ in NSSound(named: "Submarine")?.play() }
        
        AppDelegate.shared.clearCache()
        
        window.endSheet(panelWindow)
    }
    
    @IBAction func screenShot(_ sender: AnyObject?) {
        
        let frame = webView.visibleRect
        let screenshotBorder = UserDefaults.standard[.screenShotBorderWidth]
        let f = frame.insetBy(dx: -screenshotBorder, dy: -screenshotBorder)
        
        guard let rep = webView.bitmapImageRepForCachingDisplay(in: f) else { return }
        
        webView.cacheDisplay(in: frame, to: rep)
        AppDelegate.shared.registerScreenshot(rep, fromOnScreen: .zero)
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        
        if menuItem.action == .reloadContent {
            
            guard let _ = webView.mainFrame,
                let frameURL = webView.mainFrameURL
                else { return true }
            
            switch frameURL {
            case GameViewController.gamePageURL:
                menuItem.title = NSLocalizedString("Reload", comment: "Reload menu, reload")
                
            case let s where s.hasPrefix(GameViewController.loginPageURLPrefix):
                menuItem.title = NSLocalizedString("Reload", comment: "Reload menu, reload")
                
            default:
                menuItem.title = NSLocalizedString("Back To Game", comment: "Reload menu, back to game")
            }
            
            return true
        }
        
        if menuItem.action == .deleteCacheAndReload {
            
            return true
        }
        
        if menuItem.action == .screenShot {
            
            return true
        }
        
        return false
    }
}

extension GameViewController: WebFrameLoadDelegate, WebUIDelegate {
    
    private static let excludeMenuItemTag = [
        WebMenuItemTagOpenLinkInNewWindow,
        WebMenuItemTagDownloadLinkToDisk,
        WebMenuItemTagOpenImageInNewWindow,
        WebMenuItemTagOpenFrameInNewWindow,
        WebMenuItemTagGoBack,
        WebMenuItemTagGoForward,
        WebMenuItemTagStop,
        WebMenuItemTagReload
    ]
    
    func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
        
        guard let path = frame.dataSource?.initialRequest.url?.path
            else { return }
        
        let handler: (JSContext?, JSValue?) -> Void = { (_, exception) in
            
            if let exception = exception {
                
                print("Caught exception in evaluteScript -> \(exception)")
                
            } else {
                
                print("Caught exception in evaluteScript")
                
            }
        }
        
        if path.hasSuffix("gadgets/ifr") {
            
            guard let context = frame.javaScriptContext
                else { return }
            
            context.exceptionHandler = handler
            context.evaluateScript(
                ["var emb = document.getElementById('flashWrap');",
                 "var rect = emb.getBoundingClientRect();",
                 "var atop = rect.top;",
                 "var aleft = rect.left;"]
                    .reduce("", +)
            )
            let top = context.objectForKeyedSubscript("atop").toDouble()
            let left = context.objectForKeyedSubscript("aleft").toDouble()
            flashTopLeft = NSPoint(x: CGFloat(left), y: webView.frame.size.height - CGFloat(top) - 480)
        }
        
        if path.hasSuffix("app_id=854854") {
            
            guard let context = frame.javaScriptContext
                else { return }
            
            context.exceptionHandler = handler
            context.evaluateScript(
                ["var iframe = document.getElementById('game_frame');",
                 "var validIframe = 0;",
                 "if(iframe) {",
                 "    validIframe = 1;",
                 "    var rect = iframe.getBoundingClientRect();",
                 "    var atop = rect.top;",
                 "    var aleft = rect.left;",
                 "}"]
                    .reduce("", +)
            )
            let validIframe = context.objectForKeyedSubscript("validIframe").toInt32()
            
            guard validIframe != 0
                else { return }
            
            let top = context.objectForKeyedSubscript("atop").toDouble()
            let left = context.objectForKeyedSubscript("aleft").toDouble()
            flashTopLeft = NSPoint(x: flashTopLeft.x + CGFloat(left), y: flashTopLeft.y - CGFloat(top))
            
            adjustFlash()
        }
    }
    
    func webView(_ sender: WebView!, contextMenuItemsForElement element: [AnyHashable: Any]!, defaultMenuItems: [Any]!) -> [Any]! {
        
        guard let menuItems = defaultMenuItems as? [NSMenuItem]
            else { return [] }
        
        return menuItems.filter { !GameViewController.excludeMenuItemTag.contains($0.tag) }
    }
}
