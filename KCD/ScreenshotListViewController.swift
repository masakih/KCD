//
//  ScreenshotListViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/30.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

private struct CacheVersionInfo {
    
    let url: URL
    
    init(url: URL, version: Int = 0) {
        
        self.url = url
        self.version = version
    }
    
    private(set) var version: Int
    
    mutating func incrementVersion() { version = version + 1 }
}

extension NSUserInterfaceItemIdentifier {
    
    static let item = NSUserInterfaceItemIdentifier("item")
}

final class ScreenshotListViewController: NSViewController {
    
    private static let def = 800.0
    private static let leftMergin = 8.0 + 1.0
    private static let rightMergin = 8.0 + 1.0
    
    var screenshots: ScreenshotModel = ScreenshotModel()
    
    @IBOutlet var screenshotsController: NSArrayController!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet var contextMenu: NSMenu!
    @IBOutlet weak var shareButton: NSButton!
    @IBOutlet weak var standardView: NSView!
    @IBOutlet weak var editorView: NSView!
    
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
    
    private var deletedPaths: [CacheVersionInfo] = []
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
    
    private var cachURL: URL {
        
        return screenshotSaveDirectoryURL.appendingPathComponent("Cache.db")
    }
    
    var indexPathsOfItemsBeingDragged: Set<IndexPath>?
    
    // MARK: - Function
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        screenshots.screenshots = loadCache()
        
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
        
        DispatchQueue.main
            .asyncAfter(deadline: .now() + 0.0001 ) { self.reloadData() }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        guard let vc = segue.destinationController as? NSViewController else { return }
        
        vc.representedObject = screenshots
    }
    
    @objc func registerImage(_ image: NSImage?) {
        
        image?.tiffRepresentation
            .flatMap { NSBitmapImageRep(data: $0) }
            .map { registerScreenshot($0, fromOnScreen: .zero) }
    }
    
    func registerScreenshot(_ image: NSBitmapImageRep, fromOnScreen: NSRect) {
        
        DispatchQueue(label: "Screenshot queue").async {
            
            guard let data = image.representation(using: .jpeg, properties: [:]) else { return }
            
            let url = self.screenshotSaveDirectoryURL
                .appendingPathComponent(self.dirName)
                .appendingPathExtension("jpg")
            let pathURL = FileManager.default.uniqueFileURL(url)
            
            do {
                
                try data.write(to: pathURL)
                
            } catch {
                
                print("Can not write image")
                return
            }
            
            DispatchQueue.main.async {
                
                let info = ScreenshotInformation(url: pathURL, version: self.cacheVersion(forUrl: pathURL))
                
                self.screenshotsController.insert(info, atArrangedObjectIndex: 0)
                let set: Set<IndexPath> = [NSIndexPath(forItem: 0, inSection: 0) as IndexPath]
                self.collectionView.selectionIndexPaths = set
                
                self.collectionView.scrollToItems(at: set, scrollPosition: .nearestHorizontalEdge)
                if UserDefaults.standard[.showsListWindowAtScreenshot] {
                    
                    self.view.window?.makeKeyAndOrderFront(nil)
                }
                
                self.saveCache()
            }
        }
    }
    
    func viewFrameDidChange(_ notification: Notification?) {
        
        maxZoom = self.maxZoom(width: collectionView.frame.size.width)
        if zoom > maxZoom { zoom = maxZoom }
    }
    
    private func realFromZoom(zoom: Double) -> CGFloat {
        
        if zoom < 0.5 { return CGFloat(ScreenshotListViewController.def * zoom * 0.6) }
        
        return CGFloat(ScreenshotListViewController.def * (0.8 * zoom * zoom * zoom  + 0.2))
    }
    
    private func maxZoom(width: CGFloat) -> Double {
        
        let w = Double(width) - ScreenshotListViewController.leftMergin - ScreenshotListViewController.rightMergin
        
        if w < 240 { return w / ScreenshotListViewController.def / 0.6 }
        if w > 800 { return 1.0 }
        
        return pow((w / ScreenshotListViewController.def - 0.2) / 0.8, 1.0 / 3.0)
    }
    
    private func reloadData() {
        
        guard let f = try? FileManager.default.contentsOfDirectory(at: screenshotSaveDirectoryURL, includingPropertiesForKeys: nil) else {
            
            print("can not read list of screenshot directory")
            return
        }
        
        let imageTypes = NSImage.imageTypes
        let ws = NSWorkspace.shared
        var current = screenshots.screenshots
        let newFiles: [URL] = f.flatMap {
            
            guard let type = try? ws.type(ofFile: $0.path) else { return nil }
            
            return imageTypes.contains(type) ? $0 : nil
        }
        
        // なくなっているものを削除
        current = current.filter { newFiles.contains($0.url) }
        
        // 新しいものを追加
        let new: [ScreenshotInformation] = newFiles.flatMap { url in
            
            let index = current.index { url == $0.url }
            
            return index == nil ? ScreenshotInformation(url: url) : nil
        }
        
        screenshots.screenshots = current + new
        
        collectionView.selectionIndexPaths = [NSIndexPath(forItem: 0, inSection: 0) as IndexPath]
        
        reloadHandler?()
        saveCache()
        
    }
    
    private func saveCache() {
        
        let data = NSKeyedArchiver.archivedData(withRootObject: screenshots.screenshots)
        
        do {
            
            try data.write(to: cachURL)
            
        } catch {
            
            print("Can not write cache: \(error)")
            
        }
    }
    
    private func loadCache() -> [ScreenshotInformation] {
        
        guard let data = try? Data(contentsOf: cachURL) else {
            
            print("can not load cach \(cachURL)")
            return []
        }
        
        guard let l = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data),
            let loaded = l as? [ScreenshotInformation] else {
                
                print("Can not decode \(cachURL)")
                return []
        }
        
        return loaded
    }
    
    private func incrementCacheVersion(forUrl url: URL) {
        
        let infos = deletedPaths.filter { $0.url == url }
        
        if var info = infos.first {
            
            info.incrementVersion()
            
        } else {
            
            deletedPaths.append(CacheVersionInfo(url: url))
            
        }
    }
    
    private func cacheVersion(forUrl url: URL) -> Int {
        
        return deletedPaths
            .filter { $0.url == url }
            .first?
            .version ?? 0
    }
}

// MARK: - IBAction
extension ScreenshotListViewController {
    
    @IBAction func reloadData(_ sender: AnyObject?) {
        
        reloadData()
    }
    
    @IBAction func delete(_ sender: AnyObject?) {
        
        let list = selectionInformations
            .map { $0.url.path }
            .map { "(\"\($0)\" as POSIX file)" }
            .joined(separator: " , ")
        let script = "tell application \"Finder\"\n"
        + "    delete { \(list) }\n"
        + "end tell"
        
        guard let aps = NSAppleScript(source: script) else { return }
        
        aps.executeAndReturnError(nil)
        
        let selectionIndexes = screenshotsController.selectionIndexes
        screenshotsController.remove(atArrangedObjectIndexes: selectionIndexes)
        selectionInformations.forEach { incrementCacheVersion(forUrl: $0.url) }
        saveCache()
        reloadHandler?()
        
        guard var index = selectionIndexes.first else { return }
        
        if arrangedInformations.count <= index {
            
            index = arrangedInformations.count - 1
        }
        collectionView.selectionIndexPaths = [NSIndexPath(forItem: index, inSection: 0) as IndexPath]
    }
    
    @IBAction func revealInFinder(_ sender: AnyObject?) {
        
        let urls = arrangedInformations.map { $0.url }
        NSWorkspace.shared.activateFileViewerSelecting(urls)
    }
}

extension ScreenshotListViewController: NSCollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> NSSize {
        
        let f = realFromZoom(zoom: zoom)
        
        return NSSize(width: f, height: f)
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
    
    @IBOutlet var screenshotTouchBar: NSTouchBar! {
        
        get { return kTouchBars[hashValue] }
        set { kTouchBars[hashValue] = newValue }
    }
    
    @IBOutlet var scrubber: NSScrubber! {
        
        get { return kScrubbers[hashValue] }
        set { kScrubbers[hashValue] = newValue }
    }
    
    @IBOutlet var sharingItem: NSSharingServicePickerTouchBarItem! {
        
        get { return kPickers[hashValue] }
        set { kPickers[hashValue] = newValue }
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        
        var array: NSArray?
        
        Bundle.main.loadNibNamed(NSNib.Name("ScreenshotTouchBar"), owner: self, topLevelObjects: &array)
        let identifiers = self.screenshotTouchBar.defaultItemIdentifiers
            + [ScreenshotListViewController.ServicesItemIdentifier]
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
                
                guard let `self` = self else { return }
                
                self.scrubber.selectedIndex = $0
            }
        }
        
        if reloadHandler == nil {
            
            reloadHandler = { [weak self] in
                
                guard let `self` = self else { return }
                
                self.scrubber.reloadData()
            }
        }
        
        return screenshotTouchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar,
                  makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        
        guard identifier == ScreenshotListViewController.ServicesItemIdentifier else { return nil }
        
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
        
        guard arrangedInformations.count > index else { return NSScrubberImageItemView() }
        
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
