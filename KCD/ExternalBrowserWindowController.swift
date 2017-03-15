//
//  ExternalBrowserWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/23.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa
import WebKit

fileprivate extension Selector {
    static let addBookmark = #selector(ExternalBrowserWindowController.addBookmark(_:))
    static let showBookmark = #selector(ExternalBrowserWindowController.showBookmark(_:))
    static let selectBookmark = #selector(ExternalBrowserWindowController.selectBookmark(_:))
    static let reloadContent = #selector(ExternalBrowserWindowController.reloadContent(_:))
    static let updateContentVisibleRect = #selector(ExternalBrowserWindowController.updateContentVisibleRect(_:))
}

class ExternalBrowserWindowController: NSWindowController {
    let managedObjectContext = BookmarkManager.shared().manageObjectContext
    
    deinit {
        webView.removeObserver(self, forKeyPath: "canGoBack")
        webView.removeObserver(self, forKeyPath: "canGoForward")
    }
    
    @IBOutlet var webView: WebView!
    @IBOutlet var goSegment: NSSegmentedControl!
    @IBOutlet var bookmarkListView: NSView!
    
    override var windowNibName: String! {
        return "ExternalBrowserWindowController"
    }
    dynamic var canResize: Bool = true {
        willSet {
            guard let window = window else { return }
            if canResize == newValue { return }
            var style = window.styleMask.rawValue
            if newValue {
                style |= NSResizableWindowMask.rawValue
            } else {
                style &= ~NSResizableWindowMask.rawValue
            }
            window.styleMask = NSWindowStyleMask(rawValue: style)
        }
    }
    dynamic var canScroll: Bool = true {
        willSet {
            guard let webView = webView else { return }
            if canScroll == newValue { return }
            if newValue {
                webView.mainFrame.frameView.allowsScrolling = true
            } else {
                webView.mainFrame.frameView.allowsScrolling = false
            }
        }
    }
    dynamic var canMovePage: Bool = true
    
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
    
    fileprivate var bookmarkShowing: Bool = false
    fileprivate var waitingBookmarkItem: Bookmark?
    
    fileprivate lazy var bookmarkListViwController: BookmarkListViewController? = {
        [weak self] in
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
        
        webView.addObserver(self, forKeyPath: "canGoBack", context: nil)
        webView.addObserver(self, forKeyPath: "canGoForward", context: nil)
        webView.applicationNameForUserAgent = AppDelegate.shared.appNameForUserAgent
        webView.frameLoadDelegate = self
    }
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "canGoBack" {
            goSegment.setEnabled(webView.canGoBack, forSegment: 0)
            return
        }
        if keyPath == "canGoForward" {
            goSegment.setEnabled(webView.canGoForward, forSegment: 1)
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    override func swipe(with event: NSEvent) {
        if event.deltaX > 0 && showsBookmarkList() {
            showBookmark(nil)
        }
        if event.deltaX < 0 && !showsBookmarkList() {
            showBookmark(nil)
        }
    }
    
    fileprivate func move(bookmark: Bookmark) {
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
    fileprivate func showsBookmarkList() -> Bool {
        return webView.frame.origin.x > 0
    }
}

// MARK: - IBAction
extension ExternalBrowserWindowController {
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let action = menuItem.action else { return false }
        switch action {
        case Selector.addBookmark:
            return webView.mainFrameURL != nil
        case Selector.showBookmark:
            if showsBookmarkList() {
                menuItem.title = NSLocalizedString("Hide Bookmark", comment: "Menu item title, Hide Bookmark")
            } else {
                menuItem.title = NSLocalizedString("Show Bookmark", comment: "Menu item title, Show Bookmark")
            }
            return true
        case Selector.selectBookmark:
            return true
        case Selector.reloadContent:
            return true
        default:
            return false
        }
    }
    
    @IBAction func selectBookmark(_ sender: AnyObject?) {
        guard let item = sender?.representedObject as? Bookmark
            else { return }
        move(bookmark: item)
    }
    @IBAction func reloadContent(_ sender: AnyObject?) {
        webView.reload(nil)
    }
    @IBAction func goHome(_ sender: AnyObject?) {
        webView.mainFrameURL = "http://www.dmm.com/"
    }
    @IBAction func clickGoBackSegment(_ sender: AnyObject?) {
        guard let cell = goSegment.cell as? NSSegmentedCell
            else { return }
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
        guard let window = window,
            let bookmark = BookmarkManager.shared().createNewBookmark()
            else { return }
        bookmark.name = window.title
        bookmark.urlString = webView.mainFrameURL
        bookmark.windowContentSize = windowContentSize
        bookmark.contentVisibleRect = contentVisibleRect
        bookmark.canResize = canResize
        bookmark.canScroll = canScroll
        bookmark.scrollDelay = 0.5
    }
    @IBAction func showBookmark(_ sender: AnyObject?) {
        guard let window = window,
            let _ = bookmarkListViwController,
            !bookmarkShowing
            else { return }
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
        
        let webAnime: [String : Any] = [
            NSViewAnimationTargetKey: webView,
            NSViewAnimationEndFrameKey: NSValue(rect: newFrame)
        ]
        let bookmarkAnime: [String : Any] = [
            NSViewAnimationTargetKey: bookmarkListView,
            NSViewAnimationEndFrameKey: NSValue(rect: frame)
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
    
    func updateContentVisibleRect(_ timer: Timer) {
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
