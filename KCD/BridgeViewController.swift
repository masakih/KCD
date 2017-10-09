//
//  BridgeViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/30.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

protocol ScreenshotSharingProvider {
    
    var contentRect: NSRect { get }
}

class BridgeViewController: NSViewController {
    
    @IBOutlet var arrayController: NSArrayController!
    
    deinit {
        
        arrayController.unbind(.contentArray)
        arrayController.unbind(.sortDescriptors)
        arrayController.unbind(.selectionIndexes)
        arrayController.unbind(.filterPredicate)
    }
    
    override var representedObject: Any? {
        
        didSet {
            guard let representedObject = representedObject as? ScreenshotModel else { return }
            
            arrayController.bind(.contentArray, to: representedObject, withKeyPath: #keyPath(ScreenshotModel.screenshots))
            arrayController.bind(.sortDescriptors, to: representedObject, withKeyPath: #keyPath(ScreenshotModel.sortDescriptors))
            arrayController.bind(.selectionIndexes, to: representedObject, withKeyPath: #keyPath(ScreenshotModel.selectedIndexes))
            arrayController.bind(.filterPredicate, to: representedObject, withKeyPath: #keyPath(ScreenshotModel.filterPredicate))
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        (sender as? NSControl)?.action = nil
        (segue.destinationController as? NSViewController)?.representedObject = representedObject
    }
}

extension BridgeViewController: NSSharingServicePickerDelegate, ScreenshotSharingProvider {
    
    @objc var contentRect: NSRect {
        
        fatalError("Must implemente")
    }
    
    private var appendKanColleTag: Bool {
        
        return UserDefaults.standard[.appendKanColleTag]
    }
    
    private var tagString: String? {
        
        let tag = LocalizedStrings.tweetTag.string
        if tag == "" { return "" }
        
        return "#\(tag)"
    }
    
    @IBAction func share(_ sender: AnyObject?) {
        
        guard let view = sender as? NSView else { return }
        
        let picker = NSSharingServicePicker(items: itemsForShareingServicePicker())
        picker.delegate = self
        picker.show(relativeTo: view.bounds, of: view, preferredEdge: .minX)
    }
    
    private func itemsForShareingServicePicker() -> [AnyObject] {
        
        guard let informations = arrayController.selectedObjects as? [ScreenshotInformation] else { return [] }
        
        let images: [NSImage] = informations.flatMap { NSImage(contentsOf: $0.url) }
        if !appendKanColleTag { return images }
        if let tag = tagString {
            
            return ["\n\(tag)" as AnyObject] + images
        }
        
        return images
    }
}

extension BridgeViewController: NSSharingServiceDelegate {
    
    func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker,
                              delegateFor sharingService: NSSharingService) -> NSSharingServiceDelegate? {
        
        return self
    }
    
    func sharingService(_ sharingService: NSSharingService, sourceFrameOnScreenForShareItem item: Any) -> NSRect {
        
        return self.view.window?.convertToScreen(contentRect) ?? .zero
    }
    
    func sharingService(_ sharingService: NSSharingService,
                        transitionImageForShareItem item: Any,
                        contentRect: UnsafeMutablePointer<NSRect>) -> NSImage? {
        
        return item as? NSImage
    }
    
    func sharingService(_ sharingService: NSSharingService,
                        sourceWindowForShareItems items: [Any],
                        sharingContentScope: UnsafeMutablePointer<NSSharingService.SharingContentScope>) -> NSWindow? {
        
        return view.window
    }
}

@available(OSX 10.12.2, *)
extension BridgeViewController: NSSharingServicePickerTouchBarItemDelegate {
    
    func items(for pickerTouchBarItem: NSSharingServicePickerTouchBarItem) -> [Any] {
        
        return itemsForShareingServicePicker()
    }
}
