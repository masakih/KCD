//
//  CombileViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/25.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

class CombileViewController: NSViewController {
    let fleet1 = FleetViewController(viewType: .miniVierticalType)!
    let fleet2 = FleetViewController(viewType: .miniVierticalType)!
    
    @IBOutlet weak var placeholder1: NSView!
    @IBOutlet weak var placeholder2: NSView!
    
    override var nibName: String! {
        return "CombileViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let placeholders: [NSView] = [placeholder1, placeholder2]
        let fleets = [fleet1, fleet2]
        zip(placeholders, fleets).enumerated().forEach {
            $0.element.1.view.frame = $0.element.0.frame
            $0.element.1.view.autoresizingMask = $0.element.0.autoresizingMask
            $0.element.0.superview?.replaceSubview($0.element.0, with: $0.element.1.view)
            $0.element.1.fleetNumber = $0.offset + 1
        }
    }
}
