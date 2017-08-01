//
//  ScreenshotEditorViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/29.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate struct EditedImage {
    
    var editedImage: NSImage
    var url: URL
    
    init(image: NSImage, url: URL) {
        
        editedImage = image
        self.url = url
    }
}

final class TrimRectInformation: NSObject {
    
    fileprivate(set) var name: String
    fileprivate(set) var rect: NSRect
    
    fileprivate init(name: String, rect: NSRect) {
        
        self.name = name
        self.rect = rect
    }
}

fileprivate extension Selector {
    
    static let done = #selector(ScreenshotEditorViewController.done(_:))
    static let changeToDetail = #selector(ScreenshotListWindowController.changeToDetail(_:))
    static let registerImage = #selector(ScreenshotListViewController.registerImage(_:))
}

final class ScreenshotEditorViewController: BridgeViewController {
    
    let trimInfo: [TrimRectInformation]
    
    override init?(nibName: String?, bundle: Bundle?) {
        
        trimInfo = [
            TrimRectInformation(name: "Status", rect: NSRect(x: 328, y: 13, width: 470, height: 365)),
            TrimRectInformation(name: "List", rect: NSRect(x: 362, y: 15, width: 438, height: 368)),
            TrimRectInformation(name: "AirplaneBase", rect: NSRect(x: 575, y: 13, width: 225, height: 358))
        ]
        currentTrimInfo = trimInfo[0]
        
        super.init(nibName: "ScreenshotEditorViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        arrayController.removeObserver(self, forKeyPath: NSSelectionIndexesBinding)
    }
    
    @IBOutlet weak var tiledImageView: TiledImageView!
    @IBOutlet weak var doneButton: NSButton!
    
    var columnCount: Int {
        
        get { return tiledImageView.columnCount }
        set {
            tiledImageView.columnCount = newValue
            UserDefaults.standard.screenshotEditorColumnCount = newValue
        }
    }
    
    var image: NSImage? {
        
        return tiledImageView.image
    }
    
    dynamic var currentTrimInfoIndex: Int {
        
        get { return realiesCurrentTrimInforIndex }
        set {
            guard 0..<trimInfo.count ~= newValue
                else { return }
            
            realiesCurrentTrimInforIndex = newValue
            currentTrimInfo = trimInfo[newValue]
        }
    }
    
    private var editedImage: NSImage?
    private var currentSelection: [ScreenshotInformation] = []
    private var editedImages: [EditedImage] = []
    private var realiesCurrentTrimInforIndex = UserDefaults.standard.scrennshotEditorType
    private var currentTrimInfo: TrimRectInformation {
        
        didSet {
            makeEditedImage()
            trimInfo
                .index {
                    
                    if $0.name != currentTrimInfo.name { return false }
                    return $0.rect == currentTrimInfo.rect
                }
                .map { UserDefaults.standard.scrennshotEditorType = $0 }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        arrayController.addObserver(self, forKeyPath: NSSelectionIndexesBinding, context: nil)
        currentTrimInfoIndex = UserDefaults.standard.scrennshotEditorType
        updateSelections()
    }
    
    override func viewWillAppear() {
        
        doneButton.action = .done
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == NSSelectionIndexesBinding {
            
            updateSelections()
            
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    private func updateSelections() {
        
        guard let selection = arrayController.selectedObjects as? [ScreenshotInformation]
            else { return }
        
        if selection == currentSelection { return }
        
        let removed: [ScreenshotInformation] = currentSelection.flatMap {
            
            selection.contains($0) ? nil : $0
        }
        
        let appended: [ScreenshotInformation] = selection.flatMap {
            
            currentSelection.contains($0) ? nil : $0
        }
        
        removed.forEach {
            
            removeEditedImage(url: $0.url)
        }
        
        appended.forEach {
            
            appendEditedImage(url: $0.url)
        }
        
        currentSelection = selection
        makeEditedImage()
    }
    
    private func removeEditedImage(url: URL) {
        
        _ = editedImages
            .index { $0.url == url }
            .map { editedImages.remove(at: $0) }
    }
    
    private func appendEditedImage(url: URL) {
        
        NSImage(contentsOf: url)
            .flatMap { EditedImage(image: $0, url: url) }
            .map { editedImages.append($0) }
    }
    
    private func makeEditedImage() {
        
        guard !editedImages.isEmpty else {
            tiledImageView.images = []
            return
        }
        
        DispatchQueue(label: "makeTrimedImage queue")
            .async {
                
                let images: [NSImage] = self.editedImages.flatMap {
                    
                    guard let originalImage = NSImage(contentsOf: $0.url) else { return nil }
                    
                    let trimedImage = NSImage(size: self.currentTrimInfo.rect.size)
                    
                    trimedImage.lockFocus()
                    originalImage.draw(at: .zero,
                                       from: self.currentTrimInfo.rect,
                                       operation: NSCompositeCopy,
                                       fraction: 1.0)
                    trimedImage.unlockFocus()
                    
                    return trimedImage
                }
                
                DispatchQueue.main.async {
                    
                    self.tiledImageView.images = images
                }
        }
    }
    
    // TODO: 外部から End Handlerを登録できるようにして依存をなくす
    @IBAction func done(_ sender: AnyObject?) {
        
        NSApplication.shared().sendAction(.registerImage, to: nil, from: self.image)
        NSApplication.shared().sendAction(.changeToDetail, to: nil, from: sender)
    }
}
