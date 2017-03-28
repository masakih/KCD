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
        [NSContentArrayBinding, NSSortDescriptorsBinding,
         NSSelectionIndexesBinding, NSFilterPredicateBinding]
            .forEach { arrayController.unbind($0) }
    }
    
    override var representedObject: Any? {
        didSet {
            guard let representedObject = representedObject else { return }
            [
                (NSContentArrayBinding, #keyPath(ScreenshotModel.screenshots)),
                (NSSortDescriptorsBinding, #keyPath(ScreenshotModel.sortDescriptors)),
                (NSSelectionIndexesBinding, #keyPath(ScreenshotModel.selectedIndexes)),
                (NSFilterPredicateBinding, #keyPath(ScreenshotModel.filterPredicate))
                ]
                .forEach {
                    arrayController.bind($0.0, to: representedObject, withKeyPath: $0.1, options: nil)
            }
        }
    }
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        (sender as? NSControl)?.action = nil
        (segue.destinationController as? NSViewController)?.representedObject = representedObject
    }
}

extension BridgeViewController: NSSharingServicePickerDelegate, ScreenshotSharingProvider {
    var contentRect: NSRect {
        fatalError("Must implemente")
    }
    private var appendKanColleTag: Bool {
        return UserDefaults.standard.appendKanColleTag
    }
    private var tagString: String? {
        let tag = NSLocalizedString("kancolle", comment: "kancolle twitter hash tag")
        if tag == "" { return "" }
        return "#\(tag)"
    }
    @IBAction func share(_ sender: AnyObject?) {
        guard let view = sender as? NSView else { return }
        let picker = NSSharingServicePicker(items: itemsForShareingServicePicker())
        picker.delegate = self
        picker.show(relativeTo: view.bounds, of: view, preferredEdge: .minX)
    }
    
    fileprivate func itemsForShareingServicePicker() -> [AnyObject] {
        guard let informations = arrayController.selectedObjects as? [ScreenshotInformation]
            else { return [] }
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
                        sharingContentScope: UnsafeMutablePointer<NSSharingContentScope>) -> NSWindow? {
        return view.window
    }
}

@available(OSX 10.12.2, *)
extension BridgeViewController: NSSharingServicePickerTouchBarItemDelegate {
    func items(for pickerTouchBarItem: NSSharingServicePickerTouchBarItem) -> [Any] {
        return itemsForShareingServicePicker()
    }
}
