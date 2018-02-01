//
//  ScreenshotCollectionViewItem.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/29.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa
import Quartz

final class ScreenshotCollectionViewItem: NSCollectionViewItem {
    
    @IBOutlet private weak var imageBox: NSBox!
    @IBOutlet private weak var nameField: NSTextField!
    @IBOutlet private weak var nameBox: NSBox!
    
    var info: ScreenshotInformation? {
        
        return representedObject as? ScreenshotInformation
    }
    
    var imageFrame: NSRect {
        
        guard let imageView = imageView else { fatalError("ScreenshotCollectionViewItem: imageView is nil") }
        
        let frame = centerFitRect(imageView.image, target: imageView.frame)
        
        return view.convert(frame, from: imageBox)
    }
    
    override var isSelected: Bool {
        
        didSet {
            (imageBox.fillColor, nameField.textColor, nameBox.fillColor) = {
                
                if isSelected {
                    
                    return (.controlHighlightColor, .white, .alternateSelectedControlColor)
                    
                } else {
                    
                    return (.white, .black, .white)
                }
            }()
        }
    }
    
    private func centerFitRect(_ image: NSImage?, target: NSRect) -> NSRect {
        
        guard let image = image else { return target }
        
        let imageSize = image.size
        
        let ratioX = target.size.height / imageSize.height
        let ratioY = target.size.width / imageSize.width
        let ratio = min(ratioY, ratioX)
        let fitSize = NSSize(width: imageSize.width * ratio, height: imageSize.height * ratio)
        let left = (target.size.width - fitSize.width) * 0.5
        let bottom = (target.size.height - fitSize.height) * 0.5
        
        return NSRect(x: left, y: bottom, width: fitSize.width, height: fitSize.height)
    }
}

extension ScreenshotCollectionViewItem: QLPreviewItem, Previewable {
    
    var previewItemURL: URL! {
        
        return info?.url
    }
}

extension ScreenshotCollectionViewItem: NibLoadable { }
