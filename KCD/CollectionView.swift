//
//  CollectionView.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/02.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import Quartz

class CollectionView: NSCollectionView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.addObserver(self, forKeyPath: "selectionIndexPaths", context: nil)
    }
    deinit {
        self.removeObserver(self, forKeyPath: "selectionIndexPaths")
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if let o = object as? CollectionView, o == self {
            if !QLPreviewPanel.sharedPreviewPanelExists() { return }
            if !QLPreviewPanel.shared().isVisible { return }
            DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now(), execute: {
                QLPreviewPanel.shared().reloadData()
            })
            return
        }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
}

extension CollectionView {
    override func rightMouseDown(with event: NSEvent) {
        guard let menu = menu else { return }
        
        let mouse = convert(event.locationInWindow, from: nil)
        guard let indexPath = indexPathForItem(at: mouse),
            let _ = item(at: indexPath)
            else { return }
        if !selectionIndexPaths.contains(indexPath) {
            deselectAll(nil)
            selectionIndexPaths = [indexPath]
        }
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
    override func keyDown(with event: NSEvent) {
        let key = event.charactersIgnoringModifiers
        if key == " " { return quickLook(with: event) }
        
        //  左右矢印キーの時の動作
        let leftArrow: UInt16 = 123
        let rightArrow: UInt16 = 124
        if event.keyCode == leftArrow || event.keyCode == rightArrow {
            guard selectionIndexPaths.count != 0 else { return }
            var index = selectionIndexPaths.first!.item
            if event.keyCode == leftArrow && index != 0 { index -= 1 }
            if event.keyCode == rightArrow && index != content.count - 1 { index += 1 }
            let newIndexPath = IndexPath(item: index, section: 0)
            let set: Set<IndexPath> = [newIndexPath]
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
        let selections = selectionIndexPaths.flatMap { item(at: $0) }
        guard 0..<selections.count ~= index,
            let item = selections[index] as? QLPreviewItem
            else { return nil }
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
        guard let item = item as? ScreenshotCollectionViewItem
            else { return .zero }
        let frame = convert(item.imageFrame, from: item.view)
        let byWindow = convert(frame, to: nil)
        return window?.convertToScreen(byWindow) ?? .zero
    }
}
