//
//  ExternalBrowserWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/23.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa
import WebKit

private extension Selector {
    
    static let updateContentVisibleRect = #selector(ExternalBrowserWindowController.updateContentVisibleRect(_:))
}

final class ExternalBrowserWindowController: NSWindowController {
        
    @IBOutlet var webView: WebView!
    @IBOutlet var goSegment: NSSegmentedControl!
    @IBOutlet var bookmarkListView: NSView!
    
    private var canGoBackObservation: NSKeyValueObservation?
    private var canGoForwardObservation: NSKeyValueObservation?
    
    override var windowNibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    @objc dynamic var canResize: Bool = true {
        
        willSet {
            guard let window = window else { return }
            
            if canResize == newValue { return }
            
            var styleMask = window.styleMask
            if newValue {
                
                styleMask.insert(.resizable)
                
            } else {
                
                styleMask.remove(.resizable)
            }
            
            window.styleMask = styleMask
        }
    }
    
    @objc dynamic var canScroll: Bool = true {
        
        willSet {
            guard let webView = webView else { return }
            
            if canScroll == newValue { return }
            
            webView.mainFrame.frameView.allowsScrolling = newValue
        }
    }
    @objc dynamic var canMovePage: Bool = true
    
    var urlString: String? {
        
        return webView.mainFrameURL
    }
    
    var windowContentSize: NSSize {
        
        get {
            guard let window = window else { return .zero }
            
            return window.contentRect(forFrameRect: window.frame).size
        }
        set {
            guard let window = window else { return }
            
            var contentRect: NSRect = .zero
            contentRect.size = newValue
            var newFrame = window.frameRect(forContentRect: contentRect)
            let frame = window.frame
            newFrame.origin.x = frame.minX
            newFrame.origin.y = frame.maxY - newFrame.height
            window.setFrame(newFrame, display: true)
        }
    }
    
    var contentVisibleRect: NSRect {
        
        get { return webView.mainFrame.frameView.documentView.visibleRect }
        set { webView.mainFrame.frameView.documentView.scrollToVisible(newValue) }
    }
    
    private var bookmarkShowing: Bool = false
    private var waitingBookmarkItem: Bookmark?
    
    private lazy var bookmarkListViwController: BookmarkListViewController? = { [weak self] in
        
        guard let `self` = self else { return nil }
        
        let controller = BookmarkListViewController()
        self.bookmarkListView = controller.view
        controller.delegate = self
        
        var frame = self.webView.frame
        frame.size.width = 200
        frame.origin.x = -200
        self.bookmarkListView.frame = frame
        self.webView.superview?.addSubview(self.bookmarkListView, positioned: .below, relativeTo: self.webView)
        
        return controller
    }()
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        canGoBackObservation = webView.observe(\WebView.canGoBack) { [weak self] _, _ in
            
            guard let `self` = self else { return }
            
            self.goSegment.setEnabled(self.webView.canGoBack, forSegment: 0)
        }
        canGoForwardObservation = webView.observe(\WebView.canGoForward) { [weak self] _, _ in
            
            guard let `self` = self else { return }
            
            self.goSegment.setEnabled(self.webView.canGoForward, forSegment: 1)
        }
        
        webView.applicationNameForUserAgent = AppDelegate.shared.appNameForUserAgent
        webView.frameLoadDelegate = self
    }
    
    override func swipe(with event: NSEvent) {
        
        if event.deltaX > 0 && showsBookmarkList() {
            
            showBookmark(nil)
        }
        
        if event.deltaX < 0 && !showsBookmarkList() {
            
            showBookmark(nil)
        }
    }
    
    private func move(bookmark: Bookmark) {
        
        if !canMovePage {
            
            AppDelegate.shared.createNewBrowser().move(bookmark: bookmark)
            return
        }
        
        webView.mainFrameURL = bookmark.urlString
        windowContentSize = bookmark.windowContentSize
        canResize = bookmark.canResize
        canScroll = bookmark.canScroll
        waitingBookmarkItem = bookmark
    }
    
    private func showsBookmarkList() -> Bool {
        
        return webView.frame.origin.x > 0
    }
}

extension ExternalBrowserWindowController: NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        
        webView.policyDelegate = nil
        webView.uiDelegate = nil
        webView.downloadDelegate = nil
        webView.frameLoadDelegate = nil
    }
}

// MARK: - IBAction
extension ExternalBrowserWindowController {
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        
        guard let action = menuItem.action else { return false }
        
        switch action {
            
        case #selector(ExternalBrowserWindowController.addBookmark(_:)):
            return webView.mainFrameURL != nil
            
        case #selector(ExternalBrowserWindowController.showBookmark(_:)):
            if showsBookmarkList() {
                
                menuItem.title = LocalizedStrings.hideBookmark.string
                
            } else {
                
                menuItem.title = LocalizedStrings.showBookmark.string
            }
            return true
            
        case #selector(ExternalBrowserWindowController.selectBookmark(_:)):
            return true
            
        case #selector(ExternalBrowserWindowController.reloadContent(_:)):
            return true
            
        default:
            return false
        }
    }
    
    @IBAction func selectBookmark(_ sender: AnyObject?) {
        
        guard let item = sender?.representedObject as? Bookmark else { return }
        
        move(bookmark: item)
    }
    
    @IBAction func reloadContent(_ sender: AnyObject?) {
        
        webView.reload(nil)
    }
    
    @IBAction func goHome(_ sender: AnyObject?) {
        
        webView.mainFrameURL = "http://www.dmm.com/"
    }
    
    @IBAction func clickGoBackSegment(_ sender: AnyObject?) {
        
        guard let cell = goSegment.cell as? NSSegmentedCell else { return }
        
        let tag = cell.tag(forSegment: cell.selectedSegment)
        switch tag {
        case 0:
            webView.goBack(nil)
            
        case 1:
            webView.goForward(nil)
            
        default:
            break
        }
    }
    
    @IBAction func addBookmark(_ sender: AnyObject?) {
        
        guard let window = window else { return }
        guard let bookmark = BookmarkManager.shared().createNewBookmark() else { return }
        
        bookmark.name = window.title
        bookmark.urlString = webView.mainFrameURL
        bookmark.windowContentSize = windowContentSize
        bookmark.contentVisibleRect = contentVisibleRect
        bookmark.canResize = canResize
        bookmark.canScroll = canScroll
        bookmark.scrollDelay = 0.5
    }
    
    @IBAction func showBookmark(_ sender: AnyObject?) {
        
        guard let window = window else { return }
        guard let _ = bookmarkListViwController else { return }
        guard !bookmarkShowing else { return }
        
        bookmarkShowing = true
        
        var frame = bookmarkListView.frame
        frame.size.height = webView.frame.size.height
        bookmarkListView.frame = frame
        
        var newFrame = webView.frame
        
        if showsBookmarkList() {
            
            frame.origin.x = -200
            newFrame.origin.x = 0
            newFrame.size.width = window.frame.size.width
            
        } else {
            
            frame.origin.x = 0
            newFrame.origin.x = 200
            newFrame.size.width = window.frame.size.width - 200
        }
        
        let webAnime: [NSViewAnimation.Key: Any] = [
            .target: webView,
            .endFrame: NSValue(rect: newFrame)
        ]
        let bookmarkAnime: [NSViewAnimation.Key: Any] = [
            .target: bookmarkListView,
            .endFrame: NSValue(rect: frame)
        ]
        let anime = NSViewAnimation(viewAnimations: [webAnime, bookmarkAnime])
        anime.delegate = self
        anime.start()
    }
    
    @IBAction func scrollLeft(_ sender: AnyObject?) {
        
        var rect = contentVisibleRect
        rect.origin.x += 1
        contentVisibleRect = rect
    }
    
    @IBAction func scrollRight(_ sender: AnyObject?) {
        
        var rect = contentVisibleRect
        rect.origin.x -= 1
        contentVisibleRect = rect
    }
    
    @IBAction func scrollUp(_ sender: AnyObject?) {
        
        var rect = contentVisibleRect
        rect.origin.y += 1
        contentVisibleRect = rect
    }
    
    @IBAction func scrollDown(_ sender: AnyObject?) {
        
        var rect = contentVisibleRect
        rect.origin.y -= 1
        contentVisibleRect = rect
    }
    
    @IBAction func increaseWidth(_ sender: AnyObject?) {
        
        guard let window = window else { return }
        
        var frame = window.frame
        frame.size.width += 1
        window.setFrame(frame, display: true)
    }
    
    @IBAction func decreaseWidth(_ sender: AnyObject?) {
        
        guard let window = window else { return }
        
        var frame = window.frame
        frame.size.width -= 1
        window.setFrame(frame, display: true)
    }
    
    @IBAction func increaseHeight(_ sender: AnyObject?) {
        
        guard let window = window else { return }
        
        var frame = window.frame
        frame.size.height += 1
        frame.origin.y -= 1
        window.setFrame(frame, display: true)
    }
    
    @IBAction func decreaseHeight(_ sender: AnyObject?) {
        
        guard let window = window else { return }
        
        var frame = window.frame
        frame.size.height -= 1
        frame.origin.y += 1
        window.setFrame(frame, display: true)
    }
}

extension ExternalBrowserWindowController: BookmarkListViewControllerDelegate {
    
    func didSelectBookmark(_ bookmark: Bookmark) {
        
        move(bookmark: bookmark)
    }
}

extension ExternalBrowserWindowController: NSAnimationDelegate {
    
    func animationDidEnd(_ animation: NSAnimation) {
        
        bookmarkShowing = false
    }
}

extension ExternalBrowserWindowController: WebFrameLoadDelegate, WebPolicyDelegate {
    
    @objc func updateContentVisibleRect(_ timer: Timer) {
        
        guard let item = timer.userInfo as? Bookmark else { return }
        
        contentVisibleRect = item.contentVisibleRect
    }
    
    func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
        
        if let waitingBookmarkItem = waitingBookmarkItem {
            
            Timer.scheduledTimer(timeInterval: waitingBookmarkItem.scrollDelay,
                                 target: self,
                                 selector: .updateContentVisibleRect,
                                 userInfo: waitingBookmarkItem,
                                 repeats: false)
        }
        waitingBookmarkItem = nil
    }
    
    func webView(_ webView: WebView!,
                 decidePolicyForNavigationAction actionInformation: [AnyHashable: Any]!,
                 request: URLRequest!,
                 frame: WebFrame!,
                 decisionListener listener: WebPolicyDecisionListener!) {
        
        if actionInformation?[WebActionNavigationTypeKey] as? WebNavigationType == .linkClicked {
            
            if canMovePage {
                
                listener.use()
            }
            
            return
        }
        
        listener.use()
    }
}
