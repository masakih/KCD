//
//  ScreenshotDetailViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/29.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class ScreenshotDetailViewController: BridgeViewController {
    
    @IBOutlet private var imageView: ImageView!
    
    override var nibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    override var contentRect: NSRect {
        
        return imageView.convert(imageView.imageRect, to: nil)
    }
    
    private var currentSelection: [ScreenshotInformation] = []
    
    private var selectionObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        selectionObservation = arrayController.observe(\NSArrayController.selectionIndexes) { [weak self] (_, _) in
            
            self?.updateSelections()
        }
        
        updateSelections()
    }
    
    private func updateSelections() {
        
        guard let selection = arrayController.selectedObjects as? [ScreenshotInformation] else {
            
            return
        }
        
        if currentSelection == selection {
            
            return
        }
        
        imageView.images = selection.compactMap { NSImage(contentsOf: $0.url) }
        currentSelection = selection
    }
}
