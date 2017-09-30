//
//  AncherageRepairTimerViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/29.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class AncherageRepairTimerViewController: NSViewController {
    
    static let regularHeight: CGFloat = 76
    static let smallHeight: CGFloat = regularHeight - 32
    
    private let anchorageRepairManager = AnchorageRepairManager.default
    
    @IBOutlet var screenshotButton: NSButton!
    
    @objc dynamic var repairTime: NSNumber?
    
    override var nibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    var controlSize: NSControl.ControlSize = .regular {
        
        willSet {
            if controlSize == newValue { return }
            var frame = view.frame
            frame.size.height = (newValue == .regular ? type(of: self).regularHeight : type(of: self).smallHeight)
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
        
        AppDelegate.shared.addCounterUpdate { [weak self] in
            
            guard let `self` = self else { return }
            
            self.repairTime = self.calcRepairTime()
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        
        screenshotButton.image = NSImage(named: NSImage.Name("Camera"))
    }
    
    override func mouseExited(with event: NSEvent) {
        
        screenshotButton.image = NSImage(named: NSImage.Name("CameraDisabled"))
    }
    
    private func refleshTrackingArea() {
        
        view.trackingAreas
            .forEach { view.removeTrackingArea($0) }
        trackingArea = NSTrackingArea(rect: screenshotButton.frame,
                                      options: [.mouseEnteredAndExited, .activeInActiveApp],
                                      owner: self,
                                      userInfo: nil)
        if let trackingArea = trackingArea {
            
            view.addTrackingArea(trackingArea)
        }
    }
    
    private func calcRepairTime() -> NSNumber? {
        
        let complete = anchorageRepairManager.repairTime.timeIntervalSince1970
        let now = Date(timeIntervalSinceNow: 0.0).timeIntervalSince1970
        let diff = complete - now
        
        return NSNumber(value: diff + 20.0 * 60)
    }
}
