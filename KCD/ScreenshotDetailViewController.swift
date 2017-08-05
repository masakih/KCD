//
//  ScreenshotDetailViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/29.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class ScreenshotDetailViewController: BridgeViewController {
    
    deinit {
        
        arrayController.removeObserver(self, forKeyPath: NSSelectionIndexesBinding)
    }
    
    @IBOutlet var imageView: ImageView!
    
    override var nibName: String! {
        
        return "ScreenshotDetailViewController"
    }
    
    override var contentRect: NSRect {
        
        return imageView.convert(imageView.imageRect, to: nil)
    }
    
    private var currentSelection: [ScreenshotInformation] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        arrayController.addObserver(self, forKeyPath: NSSelectionIndexesBinding, context: nil)
        updateSelections()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == NSSelectionIndexesBinding {
            
            updateSelections()
            
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    private func updateSelections() {
        
        guard let selection = arrayController.selectedObjects as? [ScreenshotInformation]
            else { return }
        
        if currentSelection == selection { return }
        
        imageView.images = selection.flatMap { NSImage(contentsOf: $0.url) }
        currentSelection = selection
    }
}
