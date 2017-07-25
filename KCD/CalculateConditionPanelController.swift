//
//  CalculateConditionPanelController.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/07/10.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class CalculateConditionPanelController: NSWindowController {
    
    override var windowNibName: String {
        
        return String(describing: type(of: self))
    }
    
    dynamic var condition: Double = 1
    
    private var originalCondition: Double = 1
    
    @IBAction func ok(_ sender: Any?) {
        
        exitModal()
    }
    
    @IBAction func cancel(_ sender: Any?) {
        
        condition = originalCondition
        
        exitModal()
    }
    
    private func exitModal() {
        
        self.window?.sheetParent?.endSheet(self.window!)
    }
    
    func beginModal(for mainWindow: NSWindow, completeHander handler: @escaping (Double) -> Void) {
        
        guard let window = self.window else { return }
        
        mainWindow.beginSheet(window) { _ in
            
            handler(self.condition)
        }
    }
    
}
