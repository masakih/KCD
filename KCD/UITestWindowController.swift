//
//  UITestWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class UITestWindowController: NSWindowController {
    
    @IBOutlet private var testViewPlaceholder: NSView!
    
    override var windowNibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    private var testViewController: NSViewController?
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        testViewController = viewController()
        
        guard let vc = testViewController else { return }
        
        window?.setContentSize(vc.view.frame.size)
        vc.view.autoresizingMask = testViewPlaceholder.autoresizingMask
        testViewPlaceholder.superview?.replaceSubview(testViewPlaceholder, with: vc.view)
    }
    
    private func viewController() -> NSViewController? {
        
        return nil
//        return StrengthenListViewController()
    }
}
