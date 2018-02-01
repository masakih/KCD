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

final class GameViewController: NSViewController {
    
    private static let gamePageURL = "http://www.dmm.com/netgame/social/-/gadgets/=/app_id=854854/"
    private static let loginPageURLPrefix = "https://www.dmm.com/my/-/login/=/"
    
    @IBOutlet private var webView: WebView!
    
    override var nibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    private var flashTopLeft = NSPoint(x: 2600, y: 1445)
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
        
        guard let _ = webView.mainFrameURL else {
            
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
            alert.messageText = LocalizedStrings.reloadTimeShortenMessage.string
            let format = LocalizedStrings.reloadTimeShortenInfo.string
            alert.informativeText = String(format: format, date)
            alert.runModal()
            
            return
        }
        
        webView.reload(sender)
        
        UserDefaults.standard[.prevReloadDate] = Date(timeIntervalSinceNow: 0.0)
    }
    
    @IBAction func deleteCacheAndReload(_ sender: AnyObject?) {
        
        let panel = ProgressPanel()
        
        guard let window = view.window else { return }
        guard let panelWindow = panel.window else { return }
        
        panel.title = ""
        panel.message = LocalizedStrings.deletingCacheInfo.string
        panel.animate = true
        
        window.beginSheet(panelWindow) { _ in NSSound(named: NSSound.Name("Submarine"))?.play() }
        
        AppDelegate.shared.clearCache()
        
        window.endSheet(panelWindow)
    }
    
    func screenshotOld() {
        
        let frame = webView.visibleRect
        let screenshotBorder = UserDefaults.standard[.screenShotBorderWidth]
        let f = frame.insetBy(dx: -screenshotBorder, dy: -screenshotBorder)
        
        guard let rep = webView.bitmapImageRepForCachingDisplay(in: f) else { return }
        
        webView.cacheDisplay(in: frame, to: rep)
        AppDelegate.shared.registerScreenshot(rep, fromOnScreen: .zero)
    }
    
    @available(OSX 10.13, *)
    func screenshot() {
        
        let frame = view.visibleRect
        let screenshotBorder = UserDefaults.standard[.screenShotBorderWidth]
        let f = frame.insetBy(dx: -screenshotBorder, dy: -screenshotBorder)
        let windowCoordinateFrame = view.convert(f, to: nil)
        
        guard let window = view.window else { return Logger.shared.log("Can not get window") }
        let screenCoordinsteFrame = window.convertToScreen(windowCoordinateFrame)
        
        guard let screen = NSScreen.main else { return Logger.shared.log("Can not get Screen") }
        let scFrame = screen.frame
        
        guard let cxt = window.graphicsContext?.cgContext else { return Logger.shared.log("Cannot get Context") }
        let deviceCoordinateFrame = cxt.convertToDeviceSpace(screenCoordinsteFrame)
        let raio = deviceCoordinateFrame.size.width / screenCoordinsteFrame.size.width
        
        let trimRect = CGRect(x: raio * screenCoordinsteFrame.origin.x,
                              y: raio * (scFrame.size.height - screenCoordinsteFrame.origin.y - screenCoordinsteFrame.size.height),
                              width: raio * screenCoordinsteFrame.size.width,
                              height: raio * screenCoordinsteFrame.size.height)
        
        guard let fullSizeImage = CGDisplayCreateImage(CGMainDisplayID()) else { return Logger.shared.log("Can not get Image") }
        
        guard let image = fullSizeImage.cropping(to: trimRect) else { return Logger.shared.log("Can not trim image") }
        
        let rep = NSBitmapImageRep(cgImage: image)
        
        if rep.size != NSSize(width: 800, height: 480) {
            rep.size = NSSize(width: 800, height: 480)
        }
        
        AppDelegate.shared.registerScreenshot(rep, fromOnScreen: .zero)
    }
    
    @IBAction func screenShot(_ sender: AnyObject?) {
        
        if #available(OSX 10.13, *) {
            
            screenshot()
            
        } else {
            
            screenshotOld()
        }
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        
        guard let action: Selector = menuItem.action else { return false }
        
        switch action {
            
        case #selector(GameViewController.reloadContent(_:)):
            guard let _ = webView.mainFrame else { return true }
            guard let frameURL = webView.mainFrameURL else { return true }
            
            switch frameURL {
            case GameViewController.gamePageURL:
                menuItem.title = LocalizedStrings.reload.string
                
            case let s where s.hasPrefix(GameViewController.loginPageURLPrefix):
                menuItem.title = LocalizedStrings.reload.string
                
            default:
                menuItem.title = LocalizedStrings.backToGame.string
            }
            
            return true
            
        case #selector(GameViewController.deleteCacheAndReload(_:)):
            return true
            
        case #selector(GameViewController.screenShot(_:)):
            return true
            
        default: return false
        }
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
        
        guard let path = frame.dataSource?.initialRequest.url?.path else { return }
        
        let handler: (JSContext?, JSValue?) -> Void = { (_, exception) in
            
            if let exception = exception {
                
                print("Caught exception in evaluteScript -> \(exception)")
                
            } else {
                
                print("Caught exception in evaluteScript")
            }
        }
        
        if path.hasSuffix("gadgets/ifr") {
            
            guard let context = frame.javaScriptContext else { return }
            
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
            
            guard let context = frame.javaScriptContext else { return }
            
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
            
            guard validIframe != 0 else { return }
            
            let top = context.objectForKeyedSubscript("atop").toDouble()
            let left = context.objectForKeyedSubscript("aleft").toDouble()
            flashTopLeft = NSPoint(x: flashTopLeft.x + CGFloat(left), y: flashTopLeft.y - CGFloat(top))
            
            adjustFlash()
        }
    }
    
    func webView(_ sender: WebView!, contextMenuItemsForElement element: [AnyHashable: Any]!, defaultMenuItems: [Any]!) -> [Any]! {
        
        guard let menuItems = defaultMenuItems as? [NSMenuItem] else { return [] }
        
        return menuItems.filter { !GameViewController.excludeMenuItemTag.contains($0.tag) }
    }
}
