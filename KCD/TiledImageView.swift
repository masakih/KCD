//
//  TiledImageView.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/03.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

private struct TiledImageCellInformation {
    
    let frame: NSRect
    
    init(with frame: NSRect) {
        
        self.frame = frame
    }
}

final class TiledImageView: NSView {
    
    private static let privateDraggingUTI = "com.masakih.KCD.ScreenshotDDImte"
    
    private let imageCell = NSImageCell()
    
    required init?(coder: NSCoder) {
        
        imageCell.imageAlignment = .alignCenter
        imageCell.imageScaling = .scaleProportionallyDown
        
        super.init(coder: coder)
        
        registerForDraggedTypes([NSPasteboard.PasteboardType(TiledImageView.privateDraggingUTI)])
    }
    
    override var frame: NSRect {
        
        didSet {
            calcImagePosition()
        }
    }
    
    var image: NSImage? {
        
        return imageCell.image
    }
    
    var images: [NSImage] = [] {
        
        didSet {
            calcImagePosition()
        }
    }
    
    var columnCount: Int = 2 {
        
        didSet {
            calcImagePosition()
        }
    }
    
    private var infos: [TiledImageCellInformation] = [] {
        
        didSet {
            if inLiveResize { return }
            if infos.count < 2 { currentSelection = nil }
            setTrackingArea()
        }
    }
    
    private var currentSelection: TiledImageCellInformation?
    
    override func draw(_ dirtyRect: NSRect) {
        
        NSColor.controlBackgroundColor.setFill()
        NSColor.black.setStroke()
        NSBezierPath.fill(bounds)
        NSBezierPath.defaultLineWidth = 1.0
        NSBezierPath.stroke(bounds)
        
        let cellRect = bounds.insetBy(dx: 1, dy: 1)
        NSBezierPath.clip(cellRect)
        imageCell.draw(withFrame: cellRect, in: self)
        imageCell.drawInterior(withFrame: cellRect, in: self)
        
        if let rect = currentSelection?.frame {
            
            let forcusRing = rect.insetBy(dx: 1, dy: 1)
            NSColor.keyboardFocusIndicatorColor.setStroke()
            NSBezierPath.defaultLineWidth = 2.0
            NSBezierPath.stroke(forcusRing)
        }
    }
    
    // 市松模様を描画
    private func drawCheckerIn(_ image: NSImage, checkerSize: Int = 10) {
        
        let size = image.size
        
        do {
            
            image.lockFocus()
            defer { image.unlockFocus() }
            
            NSColor.white.setFill()
            NSRect(origin: .zero, size: size).fill()
            NSColor.lightGray.setFill()
            let colTileNum = Int(ceil(size.width / CGFloat(checkerSize)))
            let rowTileNum = Int(ceil(size.height / CGFloat(checkerSize)))
            
            for i in 0..<colTileNum {
                
                for j in 0..<rowTileNum {
                    
                    if (i + j) % 2 == 1 { continue }
                    NSRect(x: i * checkerSize, y: j * checkerSize, width: checkerSize, height: checkerSize).fill()
                }
            }
        }
    }
    
    private func calcImagePosition() {
        
        let imageCount = images.count
        if imageCount == 0 {
            
            imageCell.image = nil
            needsDisplay = true
            
            return
        }
        
        let size = images[0].size
        DispatchQueue(label: "makeTrimedImage queue").async {
            
            let numberOfCol = imageCount < self.columnCount ? imageCount : self.columnCount
            let numberOfRow = imageCount / self.columnCount + ((imageCount % self.columnCount != 0) ? 1 : 0)
            let tiledImage = NSImage(size: NSSize(width: size.width * CGFloat(numberOfCol),
                                                  height: size.height * CGFloat(numberOfRow)))
            
            self.drawCheckerIn(tiledImage)
            
            // 画像の描画
            let offset = (0..<self.images.count).map {
                
                NSPoint(x: CGFloat($0 % self.columnCount) * size.width,
                        y: size.height * CGFloat(numberOfRow) - CGFloat($0 / self.columnCount + 1) * size.height)
            }
            let imageRect = NSRect(origin: .zero, size: size)
            
            
            tiledImage.lockFocus()
            zip(self.images, offset).forEach {
                
                $0.0.draw(at: $0.1, from: imageRect, operation: .copy, fraction: 1.0)
            }
            tiledImage.unlockFocus()
            
            
            let newInfos = offset.map { TiledImageCellInformation(with: NSRect(origin: $0, size: size)) }
            
            DispatchQueue.main.sync {
                
                self.imageCell.image = tiledImage
                self.infos = self.calcurated(trackingAreaInfo: newInfos)
                self.needsDisplay = true
            }
        }
    }
    
    private func calcurated(trackingAreaInfo originalInfos: [TiledImageCellInformation]) -> [TiledImageCellInformation] {
        
        guard let size = imageCell.image?.size else { return originalInfos }
        
        let bounds = self.bounds
        let ratioX = bounds.height / size.height
        let ratioY = bounds.width / size.width
        let ratio: CGFloat
        let offset: (x: CGFloat, y: CGFloat)
        if ratioX > 1 && ratioY > 1 {
            
            ratio = 1.0
            offset = (x: (bounds.width - size.width) / 2,
                      y: (bounds.height - size.height) / 2)
            
        } else if ratioX > ratioY {
            
            ratio = ratioY
            offset = (x: 0, y: (bounds.height - size.height * ratio) / 2)
            
        } else {
            
            ratio = ratioX
            offset = (x: (bounds.width - size.width * ratio) / 2, y: 0)
            
        }
        
        return originalInfos.map {
            
            NSRect(x: $0.frame.minX * ratio + offset.x,
                   y: $0.frame.minY * ratio + offset.y,
                   width: $0.frame.width * ratio,
                   height: $0.frame.height * ratio)
            }
            .map { TiledImageCellInformation(with: $0) }
    }
    
    private func removeAllTrackingAreas() {
        
        trackingAreas.forEach(removeTrackingArea)
    }
    
    private func setTrackingArea() {
        
        removeAllTrackingAreas()
        infos.forEach {
            
            let area = NSTrackingArea(rect: $0.frame,
                                      options: [.mouseEnteredAndExited, .activeInKeyWindow],
                                      owner: self,
                                      userInfo: ["info": $0])
            addTrackingArea(area)
        }
    }
}

extension TiledImageView {
    
    override func viewWillStartLiveResize() {
        
        removeAllTrackingAreas()
    }
    
    override func viewDidEndLiveResize() {
        
        calcImagePosition()
    }
    
    override func mouseEntered(with event: NSEvent) {
        
        guard let entered = event.trackingArea?.userInfo?["info"] as? TiledImageCellInformation else { return }
        
        currentSelection = entered
        needsDisplay = true
    }
    
    override func mouseExited(with event: NSEvent) {
        
        currentSelection = nil
        needsDisplay = true
    }
    
    override func mouseDown(with event: NSEvent) {
        
        let mouse = convert(event.locationInWindow, from: nil)
        
        let items = infos.enumerated().flatMap { (offset, element) -> NSDraggingItem? in
            
            if !NSMouseInRect(mouse, element.frame, isFlipped) { return nil }
            
            guard let pItem = NSPasteboardItem(pasteboardPropertyList: offset,
                                               ofType: NSPasteboard.PasteboardType(TiledImageView.privateDraggingUTI)) else {
                    
                    fatalError()
            }
            
            let item = NSDraggingItem(pasteboardWriter: pItem)
            item.setDraggingFrame(element.frame, contents: images[offset])
            
            return item
        }
        
        let session = beginDraggingSession(with: items, event: event, source: self)
        session.animatesToStartingPositionsOnCancelOrFail = true
        session.draggingFormation = .none
        
        // ドラッグ中の全てのmouseEnterイベントがドラッグ後に一気にくるため一時的にTrackingを無効化
        removeAllTrackingAreas()
    }
}

extension TiledImageView: NSDraggingSource {
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        
        return context == .withinApplication ? .move : []
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        return draggingUpdated(sender)
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        guard let types = sender.draggingPasteboard().types,
            types.contains(NSPasteboard.PasteboardType(TiledImageView.privateDraggingUTI)) else {
                
                return []
        }
        
        if !sender.draggingSourceOperationMask().contains(.move) { return [] }
        
        let mouse = convert(sender.draggingLocation(), from: nil)
        let underMouse = infos.filter { NSMouseInRect(mouse, $0.frame, isFlipped) }
        if underMouse.count == 0 {
            
            currentSelection = nil
            
        } else {
            
            currentSelection = underMouse[0]
        }
        needsDisplay = true
        
        return .move
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        
        currentSelection = nil
        needsDisplay = true
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        guard let types = sender.draggingPasteboard().types,
            types.contains(NSPasteboard.PasteboardType(TiledImageView.privateDraggingUTI)) else {
                
                return false
        }
        
        currentSelection = nil
        needsDisplay = true
        
        return true
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        guard let types = sender.draggingPasteboard().types,
            types.contains(NSPasteboard.PasteboardType(TiledImageView.privateDraggingUTI)) else {
                
                return false
        }
        
        let pboard = sender.draggingPasteboard()
        
        guard let pbItems = pboard.pasteboardItems, !pbItems.isEmpty else { return false }
        guard let index = pbItems.first?.propertyList(forType: NSPasteboard.PasteboardType(TiledImageView.privateDraggingUTI)) as? Int,
            case 0..<images.count = index else {
                
                return false
        }
        
        let mouse = convert(sender.draggingLocation(), from: nil)
        
        let underMouse = infos.enumerated().filter { NSMouseInRect(mouse, $0.element.frame, isFlipped) }
        
        guard !underMouse.isEmpty else { return false }
        
        var newImages = images
        let image = images[index]
        newImages.remove(at: index)
        newImages.insert(image, at: underMouse[0].offset)
        images = newImages
        
        return true
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        
        setTrackingArea()
    }
}
