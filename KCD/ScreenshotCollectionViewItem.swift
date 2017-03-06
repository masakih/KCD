//
//  ScreenshotCollectionViewItem.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/29.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa
import Quartz

class ScreenshotCollectionViewItem: NSCollectionViewItem {
    @IBOutlet weak var imageBox: NSBox!
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var nameBox: NSBox!
    
    var info: ScreenshotInformation? {
        return representedObject as? ScreenshotInformation
    }
    var imageFrame: NSRect {
        guard let imageView = imageView
            else { fatalError("ScreenshotCollectionViewItem: imageView is nil") }
        let frame = centerFitRect(imageView.image, target: imageView.frame)
        return view.convert(frame, from: imageBox)
    }
    
    override var isSelected: Bool {
        didSet {
            (imageBox.fillColor, nameField.textColor, nameBox.fillColor) = {
                if isSelected {
                    return (NSColor.controlHighlightColor, NSColor.white, NSColor.alternateSelectedControlColor)
                } else {
                    return (NSColor.white, NSColor.black, NSColor.white)
                }
            }()
        }
    }
    
    private func centerFitRect(_ image: NSImage?, target: NSRect) -> NSRect {
        guard let image = image else { return target }
        let imageSize = image.size
        
        var ratio: CGFloat = 1
        let ratioX = target.size.height / imageSize.height
        let ratioY = target.size.width / imageSize.width
        if ratioX > ratioY {
            ratio = ratioY
        } else {
            ratio = ratioX
        }
        let fitSize = NSMakeSize(imageSize.width * ratio, imageSize.height * ratio)
        let left = (target.size.width - fitSize.width) * 0.5
        let bottom = (target.size.height - fitSize.height) * 0.5
        return NSMakeRect(left, bottom, fitSize.width, fitSize.height)
    }
}

extension ScreenshotCollectionViewItem: QLPreviewItem {
    var previewItemURL: URL! {
        return info?.url
    }
}
