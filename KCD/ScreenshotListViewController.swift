//
//  ScreenshotListViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/30.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension NSUserInterfaceItemIdentifier {
    
    static let item = NSUserInterfaceItemIdentifier("item")
}

final class ScreenshotListViewController: NSViewController {
    
    private static let maxImageSize = 800.0
    private static let leftMergin = 8.0 + 1.0
    private static let rightMergin = 8.0 + 1.0
    
    var screenshots: ScreenshotModel = ScreenshotModel()
    
    @IBOutlet var screenshotsController: NSArrayController!
    @IBOutlet weak var collectionView: NSCollectionView!
    
    private var selectionObservation: NSKeyValueObservation?
    
    @objc dynamic var zoom: Double = UserDefaults.standard[.screenshotPreviewZoomValue] {
        
        didSet {
            collectionView.reloadData()
            UserDefaults.standard[.screenshotPreviewZoomValue] = zoom
        }
    }
    @objc dynamic var maxZoom: Double = 1.0
    
    private var collectionVisibleDidChangeHandler: ((Set<IndexPath>) -> Void)?
    private var reloadHandler: (() -> Void)?
    private var collectionSelectionDidChangeHandler: ((Int) -> Void)?
    private(set) var inLiveScrolling = false
    private var arrangedInformations: [ScreenshotInformation] {
        
        return screenshotsController.arrangedObjects as? [ScreenshotInformation] ?? []
    }
    private var selectionInformations: [ScreenshotInformation] {
        
        return screenshotsController.selectedObjects as? [ScreenshotInformation] ?? []
    }
    
    private var dirName: String {
        
        guard let name = Bundle.main.localizedInfoDictionary?["CFBundleName"] as? String,
            !name.isEmpty else {
                
                return "KCD"
        }
        
        return name
    }
    private var screenshotSaveDirectoryURL: URL {
        
        let parentURL = URL(fileURLWithPath: AppDelegate.shared.screenShotSaveDirectory)
        let url = parentURL.appendingPathComponent(dirName)
        let fm = FileManager.default
        var isDir: ObjCBool = false
        
        do {
            
            if !fm.fileExists(atPath: url.path, isDirectory: &isDir) {
                
                try fm.createDirectory(at: url, withIntermediateDirectories: false)
                
            } else if !isDir.boolValue {
                
                print("\(url) is regular file, not direcory.")
                return parentURL
            }
            
        } catch {
            
            print("Can not create screenshot save directory.")
            return parentURL
        }
        
        return url
    }
    
    var indexPathsOfItemsBeingDragged: Set<IndexPath>?
    
    // MARK: - Function
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let nib = NSNib(nibNamed: ScreenshotCollectionViewItem.nibName, bundle: nil)
        collectionView.register(nib, forItemWithIdentifier: .item)
        
        screenshots.sortDescriptors = [NSSortDescriptor(key: #keyPath(ScreenshotInformation.creationDate), ascending: false)]
        selectionObservation = collectionView.observe(\NSCollectionView.selectionIndexPaths) { [weak self] (_, _) in
            
            guard let `self` = self else { return }
            
            let selections = self.collectionView.selectionIndexPaths
            let selectionIndexes = selections.reduce(into: IndexSet()) { $0.insert($1.item) }
            self.screenshots.selectedIndexes = selectionIndexes
            selectionIndexes.first.map { self.collectionSelectionDidChangeHandler?($0) }
        }
        collectionView.postsFrameChangedNotifications = true
        
        let nc = NotificationCenter.default
        let scrollView = collectionView.enclosingScrollView
        
        nc.addObserver(forName: NSView.frameDidChangeNotification, object: collectionView, queue: nil, using: viewFrameDidChange)
        nc.addObserver(forName: NSScrollView.didLiveScrollNotification,
                       object: collectionView.enclosingScrollView, queue: nil) { _ in
                        
            let visibleItems = self.collectionView.indexPathsForVisibleItems()
            self.collectionVisibleDidChangeHandler?(visibleItems)
        }
        nc.addObserver(forName: NSScrollView.willStartLiveScrollNotification, object: scrollView, queue: nil) { _ in
            
            self.inLiveScrolling = true
        }
        nc.addObserver(forName: NSScrollView.didEndLiveScrollNotification, object: scrollView, queue: nil) { _ in
            
            self.inLiveScrolling = false
        }
        
        collectionView.setDraggingSourceOperationMask([.move, .copy, .delete], forLocal: false)
        
        viewFrameDidChange(nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001, execute: self.reloadData)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        guard let vc = segue.destinationController as? NSViewController else { return }
        
        vc.representedObject = screenshots
    }
    
    func registerImage(_ image: NSImage?) {
        
        image?.tiffRepresentation
            .flatMap { NSBitmapImageRep(data: $0) }
            .map { registerScreenshot($0, fromOnScreen: .zero) }
    }
    
    func registerScreenshot(_ image: NSBitmapImageRep, fromOnScreen: NSRect) {
        
        let register = ScreenshotRegister(screenshotSaveDirectoryURL)
        
        register.registerScreenshot(image, name: dirName) { url in
            
            let info = ScreenshotInformation(url: url)
            
            self.screenshotsController.insert(info, atArrangedObjectIndex: 0)
            let set: Set<IndexPath> = [NSIndexPath(forItem: 0, inSection: 0) as IndexPath]
            self.collectionView.selectionIndexPaths = set
            
            self.collectionView.scrollToItems(at: set, scrollPosition: .nearestHorizontalEdge)
            if UserDefaults.standard[.showsListWindowAtScreenshot] {
                
                self.view.window?.makeKeyAndOrderFront(nil)
            }
        }
    }
    
    func viewFrameDidChange(_ notification: Notification?) {
        
        maxZoom = calcMaxZoom()
        if zoom > maxZoom { zoom = maxZoom }
    }
    
    /// 画像の大きさの変化が自然になるようにzoom値から画像サイズを計算
    private func sizeFrom(zoom: Double) -> CGFloat {
        
        if zoom < 0.5 { return CGFloat(type(of: self).maxImageSize * zoom * 0.6) }
        
        return CGFloat(type(of: self).maxImageSize * (0.8 * zoom * zoom * zoom  + 0.2))
    }
    
    /// ビューの幅に合わせたzoomの最大値を計算
    private func calcMaxZoom() -> Double {
        
        let effectiveWidth = Double(collectionView.frame.size.width) - type(of: self).leftMergin - type(of: self).rightMergin
        
        if effectiveWidth < 240 { return effectiveWidth / type(of: self).maxImageSize / 0.6 }
        if effectiveWidth > 800 { return 1.0 }
        
        return pow((effectiveWidth / type(of: self).maxImageSize - 0.2) / 0.8, 1.0 / 3.0)
    }
    
    private func reloadData() {
        
        Promise<[ScreenshotInformation]>()
            .complete {
                Result(ScreenshotLoader(self.screenshotSaveDirectoryURL).merge(screenshots: []))
            }
            .future
            .onSuccess { screenshots in
                
                DispatchQueue.main.async {
                    self.screenshots.screenshots = screenshots
                    
                    self.collectionView.selectionIndexPaths = [NSIndexPath(forItem: 0, inSection: 0) as IndexPath]
                    
                    self.reloadHandler?()
                }
        }
    }
    
}

// MARK: - IBAction
extension ScreenshotListViewController {
    
    @IBAction func reloadContent(_ sender: AnyObject?) {
        
        reloadData()
    }
    
    @IBAction func reloadData(_ sender: AnyObject?) {
        
        reloadData()
    }
    
    private func moveToTrash(_ urls: [URL]) {
        
        let list = urls.map { $0.path }
            .map { "(\"\($0)\" as POSIX file)" }
            .joined(separator: " , ")
        let script = "tell application \"Finder\"\n"
            + "    delete { \(list) }\n"
            + "end tell"
        
        guard let aps = NSAppleScript(source: script) else { return }
        
        aps.executeAndReturnError(nil)
    }
    
    @IBAction func delete(_ sender: AnyObject?) {
        
        let selectionURLs = selectionInformations.map { $0.url }
        
        let selectionIndexes = screenshotsController.selectionIndexes
        screenshotsController.remove(atArrangedObjectIndexes: selectionIndexes)
        reloadHandler?()
        
        guard var index = selectionIndexes.first else { return }
        
        if arrangedInformations.count <= index {
            
            index = arrangedInformations.count - 1
        }
        collectionView.selectionIndexPaths = [NSIndexPath(forItem: index, inSection: 0) as IndexPath]
        
        moveToTrash(selectionURLs)
    }
    
    @IBAction func revealInFinder(_ sender: AnyObject?) {
        
        let urls = selectionInformations.map { $0.url }
        NSWorkspace.shared.activateFileViewerSelecting(urls)
    }
}

extension ScreenshotListViewController: NSCollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> NSSize {
        
        let size = sizeFrom(zoom: zoom)
        
        return NSSize(width: size, height: size)
    }
    
    // Drag and Drop
    func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexPaths: Set<IndexPath>, with event: NSEvent) -> Bool {
        
        return true
    }
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        
        return arrangedInformations[indexPath.item].url.absoluteURL as NSURL
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
        
        indexPathsOfItemsBeingDragged = indexPaths
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
        
        defer { indexPathsOfItemsBeingDragged = nil }
        
        guard let dragged = indexPathsOfItemsBeingDragged else { return }
        guard operation.contains(.move) || operation.contains(.delete) else { return }
        
        var indexes = IndexSet()
        dragged.forEach { indexes.insert($0.item) }
        
        screenshotsController.remove(atArrangedObjectIndexes: indexes)
    }
    
}

@available(OSX 10.12.2, *)
private var kTouchBars: [Int: NSTouchBar] = [:]
@available(OSX 10.12.2, *)
private var kScrubbers: [Int: NSScrubber] = [:]
@available(OSX 10.12.2, *)
private var kPickers: [Int: NSSharingServicePickerTouchBarItem] = [:]

@available(OSX 10.12.2, *)
extension ScreenshotListViewController: NSTouchBarDelegate {
    
    static let ServicesItemIdentifier: NSTouchBarItem.Identifier
        = NSTouchBarItem.Identifier(rawValue: "com.masakih.sharingTouchBarItem")
    
    @IBOutlet private var screenshotTouchBar: NSTouchBar! {
        
        get { return kTouchBars[hashValue] }
        set { kTouchBars[hashValue] = newValue }
    }
    
    @IBOutlet private var scrubber: NSScrubber! {
        
        get { return kScrubbers[hashValue] }
        set { kScrubbers[hashValue] = newValue }
    }
    
    @IBOutlet private var sharingItem: NSSharingServicePickerTouchBarItem! {
        
        get { return kPickers[hashValue] }
        set { kPickers[hashValue] = newValue }
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        
        Bundle.main.loadNibNamed(NSNib.Name("ScreenshotTouchBar"), owner: self, topLevelObjects: nil)
        let identifiers = self.screenshotTouchBar.defaultItemIdentifiers
            + [type(of: self).ServicesItemIdentifier]
        screenshotTouchBar.defaultItemIdentifiers = identifiers
        
        if collectionVisibleDidChangeHandler == nil {
            
            collectionVisibleDidChangeHandler = { [weak self] in
                
                guard let `self` = self else { return }
                guard let index = $0.first else { return }
                
                let middle = index.item + $0.count / 2
                
                if middle < self.arrangedInformations.count - 1 {
                    
                    self.scrubber.scrollItem(at: middle, to: .none)
                }
            }
        }
        
        if collectionSelectionDidChangeHandler == nil {
            
            collectionSelectionDidChangeHandler = { [weak self] in
                
                self?.scrubber.selectedIndex = $0
            }
        }
        
        if reloadHandler == nil {
            
            reloadHandler = { [weak self] in
                
                self?.scrubber.reloadData()
            }
        }
        
        return screenshotTouchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar,
                  makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        
        guard identifier == type(of: self).ServicesItemIdentifier else { return nil }
        
        if sharingItem == nil {
            
            sharingItem = NSSharingServicePickerTouchBarItem(identifier: identifier)
            
            if let w = view.window?.windowController as? NSSharingServicePickerTouchBarItemDelegate {
                
                sharingItem.delegate = w
            }
        }
        return sharingItem
    }
}

@available(OSX 10.12.2, *)
extension ScreenshotListViewController: NSScrubberDataSource, NSScrubberDelegate {
    
    func numberOfItems(for scrubber: NSScrubber) -> Int {
        
        return arrangedInformations.count
    }
    
    func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
        
        guard case 0..<arrangedInformations.count = index else { return NSScrubberImageItemView() }
        
        let info = arrangedInformations[index]
        let itemView = NSScrubberImageItemView()
        
        if let image = NSImage(contentsOf: info.url) {
            
            itemView.image = image
        }
        
        return itemView
    }
    
    func scrubber(_ scrubber: NSScrubber, didSelectItemAt selectedIndex: Int) {
        
        let p = NSIndexPath(forItem: selectedIndex, inSection: 0) as IndexPath
        
        collectionView.selectionIndexPaths = [p]
    }
    
    func scrubber(_ scrubber: NSScrubber, didChangeVisibleRange visibleRange: NSRange) {
        
        if inLiveScrolling { return }
        
        let center = visibleRange.location + visibleRange.length / 2
        let p = NSIndexPath(forItem: center, inSection: 0) as IndexPath
        collectionView.scrollToItems(at: [p], scrollPosition: [.centeredVertically])
    }
}
