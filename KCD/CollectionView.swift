//
//  CollectionView.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import Quartz

protocol Previewable {
    
    var imageFrame: NSRect { get }
    var view: NSView { get }
}

final class CollectionView: NSCollectionView {
    
    private var selectionObservation: NSKeyValueObservation?
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        selectionObservation = observe(\CollectionView.selectionIndexPaths) { (_, _) in
            
            if !QLPreviewPanel.sharedPreviewPanelExists() {
                
                return
            }
            if !QLPreviewPanel.shared().isVisible {
                
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                
                QLPreviewPanel.shared().reloadData()
            }
        }
    }
    
}

extension CollectionView {
    
    override func rightMouseDown(with event: NSEvent) {
        
        guard let menu = menu else {
            
            return
        }
        
        let mouse = convert(event.locationInWindow, from: nil)
        
        guard let indexPath = indexPathForItem(at: mouse) else {
            
            return
        }
        guard let _ = item(at: indexPath) else {
            
            return
        }
        
        if !selectionIndexPaths.contains(indexPath) {
            
            deselectAll(nil)
            selectionIndexPaths = [indexPath]
        }
        
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
    
    override func keyDown(with event: NSEvent) {
        
        let key = event.charactersIgnoringModifiers
        
        if key == " " {
            
            return quickLook(with: event)
        }
        
        //  左右矢印キーの時の動作
        let leftArrow: UInt16 = 123
        let rightArrow: UInt16 = 124
        if event.keyCode == leftArrow || event.keyCode == rightArrow {
            
            guard selectionIndexPaths.count != 0 else {
                
                return
            }
            
            var index = selectionIndexPaths.first!.item
            if event.keyCode == leftArrow && index != 0 {
                
                index -= 1
            }
            if event.keyCode == rightArrow && index != content.count - 1 {
                
                index += 1
            }
            let set: Set<IndexPath> = [IndexPath(item: index, section: 0)]
            scrollToItems(at: set, scrollPosition: .nearestHorizontalEdge)
            selectionIndexPaths = set
            
            return
        }
        
        super.keyDown(with: event)
    }
    
    override func quickLook(with event: NSEvent) {
        
        quickLookPreviewItems(nil)
    }
    
    override func quickLookPreviewItems(_ sender: Any?) {
        
        if QLPreviewPanel.sharedPreviewPanelExists(),
            QLPreviewPanel.shared().isVisible {
            
            QLPreviewPanel.shared().orderOut(nil)
            
        } else {
            
            QLPreviewPanel.shared().makeKeyAndOrderFront(nil)
        }
    }
}

extension CollectionView: QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    
    override func acceptsPreviewPanelControl(_ panel: QLPreviewPanel!) -> Bool {
        
        return true
    }
    
    override func beginPreviewPanelControl(_ panel: QLPreviewPanel!) {
        
        panel.dataSource = self
        panel.delegate = self
    }
    
    override func endPreviewPanelControl(_ panel: QLPreviewPanel!) {
        
        panel.dataSource = nil
        panel.delegate = nil
    }
    
    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        
        return selectionIndexPaths.count
    }
    
    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        
        let selections = selectionIndexPaths.compactMap(item(at:))
        
        guard case 0..<selections.count = index else {
            
            return nil
        }
        guard let item = selections[index] as? QLPreviewItem else {
            
            return nil
        }
        
        return item
    }
    
    func previewPanel(_ panel: QLPreviewPanel!, handle event: NSEvent!) -> Bool {
        
        if event.type == .keyDown {
            
            keyDown(with: event)
            
            return true
        }
        
        return false
    }
    
    func previewPanel(_ panel: QLPreviewPanel!, sourceFrameOnScreenFor item: QLPreviewItem!) -> NSRect {
        
        guard let item = item as? Previewable else {
            
            return .zero
        }
        
        let frame = convert(item.imageFrame, from: item.view)
        let byWindow = convert(frame, to: nil)
        
        return window?.convertToScreen(byWindow) ?? .zero
    }
}
