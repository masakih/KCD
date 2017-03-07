//
//  AncherageRepairTimerViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/29.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

class AncherageRepairTimerViewController: NSViewController {
    
    static let regularHeight: CGFloat = 76
    static let smallHeight: CGFloat = regularHeight - 32
    
    private let anchorageRepairManager = AnchorageRepairManager.default
    
    @IBOutlet var screenshotButton:NSButton!
    
    dynamic var repairTime: NSNumber?
    override var nibName: String! {
        return "AncherageRepairTimerViewController"
    }
    var controlSize: NSControlSize = .regular {
        willSet {
            if controlSize == newValue { return }
            var frame = view.frame
            frame.size.height = newValue == .regular ? AncherageRepairTimerViewController.regularHeight : AncherageRepairTimerViewController.smallHeight
            view.frame = frame
            
            var buttonFrame = screenshotButton.frame
            buttonFrame.size.width += newValue == .regular ? 32.0 : -32.0
            screenshotButton.frame = buttonFrame
            
            refleshTrackingArea()
        }
    }
    private var trackingArea: NSTrackingArea?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        appDelegate.addCounterUpdate { [weak self] () in
            guard let `self` = self else { return }
            self.repairTime = self.calcRepairTime()
        }
    }
    override func mouseEntered(with event: NSEvent) {
        screenshotButton.image = NSImage(named: "Camera")
    }
    override func mouseExited(with event: NSEvent) {
        screenshotButton.image = NSImage(named: "CameraDisabled")
    }
    
    private func refleshTrackingArea() {
        view.trackingAreas.forEach {
            view.removeTrackingArea($0)
        }
        trackingArea = NSTrackingArea(rect: screenshotButton.frame, options: [.mouseEnteredAndExited, .activeInActiveApp], owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea!)
    }
    
    private func calcRepairTime() -> NSNumber? {
        let time = anchorageRepairManager.repairTime
        let complete = time.timeIntervalSince1970
        let now = Date(timeIntervalSinceNow: 0.0)
        let diff = complete - now.timeIntervalSince1970
        return NSNumber(value: diff + 20.0 * 60)
    }
}