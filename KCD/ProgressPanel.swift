//
//  ProgressPanel.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/20.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class ProgressPanel: NSWindowController {
    
    var title: String = ""
    var message: String = ""
    var animate: Bool = false
    
    override var windowNibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
}
