//
//  ScreenshotListWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/31.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

class ScreenshotListWindowController: NSWindowController {
    @IBOutlet weak var shareButton: NSButton!
    @IBOutlet var rightController: NSViewController!
    @IBOutlet weak var left: NSView!
    @IBOutlet weak var right: NSView!
    
    private var detailViewController: ScreenshotDetailViewController! = nil
    private var editorViewController: ScreenshotEditorViewController! = nil
    private var viewControllers: [NSViewController] = []
    fileprivate weak var currentRightViewController: BridgeViewController! = nil
    fileprivate var listViewController: ScreenshotListViewController! = nil
    
    var filterPredicate: NSPredicate? = nil {
        didSet {
            listViewController.screenshots.filterPredicate = filterPredicate
        }
    }
    
    override var windowNibName: String! {
        return "ScreenshotListWindowController"
    }
    override func windowDidLoad() {
        super.windowDidLoad()
        
        listViewController = ScreenshotListViewController()
        viewControllers.append(listViewController)
        replaceView(left, viewController: listViewController)
        listViewController.representedObject = listViewController.screenshots
        guard let _ = listViewController else {
            print("Can not load listViewController")
            return
        }
        
        detailViewController = ScreenshotDetailViewController()
        viewControllers.append(detailViewController)
        rightController.addChildViewController(detailViewController)
        replaceView(right, viewController: detailViewController)
        detailViewController.representedObject = listViewController.screenshots
        guard let _ = detailViewController else {
            print("Can not load detailViewController")
            return
        }
        
        editorViewController = ScreenshotEditorViewController()
        rightController.addChildViewController(editorViewController)
        // force load view.
        let _ = editorViewController.view
        editorViewController.representedObject = listViewController.screenshots
        guard let _ = editorViewController else {
            print("Can not load editorViewContoller")
            return
        }
        
        currentRightViewController = detailViewController
        
        shareButton.sendAction(on: [.leftMouseDown])
    }
    
    func replaceView(_ view: NSView, viewController: NSViewController) {
        viewController.view.frame = view.frame
        viewController.view.setFrameOrigin(.zero)
        viewController.view.autoresizingMask = view.autoresizingMask
        view.addSubview(viewController.view)
    }
    
    func registerScreenshot(_ image: NSBitmapImageRep, fromOnScreen: NSRect) {
        listViewController.registerScreenshot(image, fromOnScreen: fromOnScreen)
    }
    
    @IBAction func share(_ sender: AnyObject?) {
        currentRightViewController.share(sender)
    }
    @IBAction func changeToEditor(_ sender: AnyObject?) {
        rightController.transition(from: detailViewController, to: editorViewController, options: [.slideLeft], completionHandler: nil)
        currentRightViewController = editorViewController
    }
    @IBAction func changeToDetail(_ sender: AnyObject?) {
        rightController.transition(from: editorViewController, to: detailViewController, options: [.slideRight], completionHandler: nil)
        currentRightViewController = detailViewController
    }
}

extension ScreenshotListWindowController: NSSharingServicePickerDelegate {
    func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, delegateFor sharingService: NSSharingService) -> NSSharingServiceDelegate? {
        return currentRightViewController
    }
}

extension ScreenshotListWindowController: NSSplitViewDelegate {
    private static let leftMinWidth: CGFloat = 299
    private static let rightMinWidth: CGFloat = 400
    
    func splitView(_ splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        if dividerIndex == 0 { return ScreenshotListWindowController.leftMinWidth }
        return proposedMinimumPosition
    }
    func splitView(_ splitView: NSSplitView, constrainSplitPosition proposedPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        if dividerIndex == 0 {
            let rightWidth = splitView.frame.size.width - proposedPosition
            if rightWidth < ScreenshotListWindowController.rightMinWidth {
                return splitView.frame.size.width - ScreenshotListWindowController.rightMinWidth
            }
        }
        return proposedPosition
    }
    func splitView(_ splitView: NSSplitView, resizeSubviewsWithOldSize oldSize: NSSize) {
        splitView.adjustSubviews()
        
        let leftView = splitView.subviews[0]
        let rightView = splitView.subviews[1]
        if NSWidth(leftView.frame) < ScreenshotListWindowController.leftMinWidth {
            var leftRect = leftView.frame
            leftRect.size.width = ScreenshotListWindowController.leftMinWidth
            leftView.frame = leftRect
            
            var rightRect = rightView.frame
            rightRect.size.width = NSWidth(splitView.frame) - NSWidth(leftRect) - splitView.dividerThickness
            rightRect.origin.x = NSWidth(leftRect) + splitView.dividerThickness
            rightView.frame = rightRect
        }
    }
    func splitView(_ splitView: NSSplitView, shouldAdjustSizeOfSubview view: NSView) -> Bool {
        let leftView = splitView.subviews[0]
        let rightView = splitView.subviews[1]
        if leftView == view {
            if NSWidth(leftView.frame) < ScreenshotListWindowController.leftMinWidth { return false }
        }
        if rightView == view {
            if NSWidth(leftView.frame) >= ScreenshotListWindowController.leftMinWidth { return false }
        }
        return true
    }
}

@available(OSX 10.12.2, *)
extension ScreenshotListWindowController: NSSharingServicePickerTouchBarItemDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        return listViewController.touchBar
    }
    
    func items(for pickerTouchBarItem: NSSharingServicePickerTouchBarItem) -> [Any] {
        return currentRightViewController.items(for: pickerTouchBarItem)
    }
}
