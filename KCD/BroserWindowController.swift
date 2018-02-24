//
//  BroserWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/31.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class BroserWindowController: NSWindowController {
    
    enum FleetViewPosition: Int {
        
        case above = 0
        case below = 1
        case divided = 2
        case oldStyle = 0xffffffff
    }
    
    @objc override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        
        switch key {
            
        case #keyPath(flagShipName): return [#keyPath(flagShipID)]
            
        default: return []
        }
    }
    
    @objc let managedObjectContext = ServerDataStore.default.context
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet private weak var placeholder: NSView!
    @IBOutlet private weak var combinedViewPlaceholder: NSView!
    @IBOutlet private weak var deckPlaceholder: NSView!
    @IBOutlet private weak var stokerContainer: NSView!
    @IBOutlet private weak var resourcePlaceholder: NSView!
    @IBOutlet private weak var ancherageRepariTimerPlaceholder: NSView!
    @IBOutlet private weak var informationsPlaceholder: NSView!
    @IBOutlet private var deckContoller: NSArrayController!
    
    override var windowNibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    @objc var flagShipID: Int = 0
    @objc var flagShipName: String? {
        return ServerDataStore.default.ship(by: flagShipID)?.name
    }
    
    private var gameViewController: GameViewController!
    private var fleetViewController: FleetViewController!
    @objc private var informantionViewController = InformationTabViewController()
    private var ancherageRepariTimerViewController: AncherageRepairTimerViewController!
    private var resourceViewController: ResourceViewController!
    private var combinedViewController: CombileViewController!
    
    private var fleetViewPosition: FleetViewPosition = .above
    private var isCombinedMode = false
    private var isExtShpMode = false
    
    // MARK: - Function
    override func windowDidLoad() {
        
        super.windowDidLoad()
    
        gameViewController = GameViewController()
        replace(view: placeholder, with: gameViewController)
        
        replace(view: informationsPlaceholder, with: informantionViewController)
        
        resourceViewController = ResourceViewController()
        replace(view: resourcePlaceholder, with: resourceViewController)
        
        ancherageRepariTimerViewController = AncherageRepairTimerViewController()
        replace(view: ancherageRepariTimerPlaceholder, with: ancherageRepariTimerViewController)
        if UserDefaults.standard[.screenshotButtonSize] == .small { toggleAnchorageSize(nil) }
        
        fleetViewController = FleetViewController(viewType: .detailViewType)
        replace(view: deckPlaceholder, with: fleetViewController)
        setFleetView(position: UserDefaults.standard[.fleetViewPosition], animate: false)
        fleetViewController.enableAnimation = false
        fleetViewController.shipOrder = UserDefaults.standard[.fleetViewShipOrder]
        fleetViewController.enableAnimation = true
        fleetViewController.delegate = self
        
        bind(NSBindingName(rawValue: #keyPath(flagShipID)), to: deckContoller, withKeyPath: "selection.ship_0", options: nil)
        
        NotificationCenter.default
            .addObserver(forName: .CombinedDidCange, object: nil, queue: nil) {
                
                guard UserDefaults.standard[.autoCombinedView] else { return }
                guard let type = $0.userInfo?[CombinedCommand.userInfoKey] as? CombineType else { return }
                
                if !Thread.isMainThread { Thread.sleep(forTimeInterval: 0.1) }
                
                DispatchQueue.main.async {
                    
                    switch type {
                    case .cancel:
                        self.hideCombinedView()
                        
                    case .maneuver, .water, .transportation:
                        self.showCombinedView()
                    }
                }
        }
        
        if UserDefaults.standard[.lastHasCombinedView] { showCombinedView() }
    }
    
    override func swipe(with event: NSEvent) {
        
        guard UserDefaults.standard[.useSwipeChangeCombinedView] else { return }
        
        if event.deltaX > 0 {
            
            showCombinedView()
        }
        
        if event.deltaX < 0 {
            
            hideCombinedView()
        }
    }
    
    @objc func windowWillClose(_ notification: Notification) {
        
        UserDefaults.standard[.lastHasCombinedView] = isCombinedMode
    }
        
    private func showCombinedView() {
        
        if isCombinedMode { return }
        
        if fleetViewPosition == .oldStyle { return }
        
        isCombinedMode = true
        
        if combinedViewController == nil {
            
            combinedViewController = CombileViewController()
            combinedViewController.view.isHidden = true
            replace(view: combinedViewPlaceholder, with: combinedViewController)
        }
        
        var winFrame = window!.frame
        let incWid = combinedViewController.view.frame.maxX
        winFrame.size.width += incWid
        winFrame.origin.x -= incWid
        combinedViewController.view.isHidden = false
        window?.setFrame(winFrame, display: true, animate: true)
    }
    
    private func hideCombinedView() {
        
        if !isCombinedMode { return }
        
        isCombinedMode = false
        
        var winFrame = window!.frame
        let decWid = combinedViewController.view.frame.maxX
        winFrame.size.width -= decWid
        winFrame.origin.x += decWid
        window?.setFrame(winFrame, display: true, animate: true)
        combinedViewController.view.isHidden = true
    }
}

// MARK: - IBAction
extension BroserWindowController {
    
    private func showView(number: Int) {
        
        informantionViewController.selectionIndex = number
    }
    
    @IBAction func reloadContent(_ sender: AnyObject?) {
        
        gameViewController.reloadContent(sender)
    }
    
    @IBAction func deleteCacheAndReload(_ sender: AnyObject?) {
        
        gameViewController.deleteCacheAndReload(sender)
    }
    
    @IBAction func clearQuestList(_ sender: AnyObject?) {
        
        let store = ServerDataStore.oneTimeEditor()
        store.sync { store.quests().forEach(store.delete) }
    }
    
    // call from menu item
    @IBAction func selectView(_ sender: AnyObject?) {
        
        guard let tag = sender?.tag else { return }
        
        showView(number: tag)
    }
    
    // call from touch bar
    @IBAction func changeMainTab(_ sender: AnyObject?) {
        
        guard let segment = sender?.selectedSegment else { return }
        
        showView(number: segment)
    }
    
    @IBAction func screenShot(_ sender: AnyObject?) {
        
        gameViewController.screenShot(sender)
    }
    
    @IBAction func toggleAnchorageSize(_ sender: AnyObject?) {
        
        let current = ancherageRepariTimerViewController.controlSize
        var diff = AncherageRepairTimerViewController.regularHeight - AncherageRepairTimerViewController.smallHeight
        let newSize: NSControl.ControlSize = {
            
            if current == .regular {
                
                diff *= -1
                
                return .small
            }
            
            return .regular
        }()
        ancherageRepariTimerViewController.controlSize = newSize
        
        var frame = informantionViewController.view.frame
        frame.size.height -= diff
        frame.origin.y += diff
        informantionViewController.view.frame = frame
        
        UserDefaults.standard[.screenshotButtonSize] = newSize
    }
    
    @IBAction func showHideCombinedView(_ sender: AnyObject?) {
        
         isCombinedMode ? hideCombinedView() : showCombinedView()
    }
    
    @IBAction func fleetListAbove(_ sender: AnyObject?) {
        
        setFleetView(position: .above, animate: true)
    }
    
    @IBAction func fleetListBelow(_ sender: AnyObject?) {
        
        setFleetView(position: .below, animate: true)
    }
    
    @IBAction func fleetListDivide(_ sender: AnyObject?) {
        
        setFleetView(position: .divided, animate: true)
    }
    
    @IBAction func fleetListSimple(_ sender: AnyObject?) {
        
        setFleetView(position: .oldStyle, animate: true)
    }
    
    @IBAction func reorderToDoubleLine(_ sender: AnyObject?) {
        
        fleetViewController.shipOrder = .doubleLine
        UserDefaults.standard[.fleetViewShipOrder] = .doubleLine
    }
    
    @IBAction func reorderToLeftToRight(_ sender: AnyObject?) {
        
        fleetViewController.shipOrder = .leftToRight
        UserDefaults.standard[.fleetViewShipOrder] = .leftToRight
    }
    
    @IBAction func selectNextFleet(_ sender: AnyObject?) {
        
        fleetViewController.selectNextFleet(sender)
    }
    
    @IBAction func selectPreviousFleet(_ sender: AnyObject?) {
        
        fleetViewController.selectPreviousFleet(sender)
    }
    
    @IBAction func changeSakutekiCalculator(_ sender: Any?) {
        
        fleetViewController.changeSakutekiCalculator(sender)
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        
        guard let action: Selector = menuItem.action else { return false }
        
        switch action {
            
        case #selector(BroserWindowController.reloadContent(_:)),
             #selector(BroserWindowController.screenShot(_:)),
             #selector(BroserWindowController.deleteCacheAndReload(_:)):
            
            return gameViewController.validateMenuItem(menuItem)
            
        case #selector(BroserWindowController.selectView(_:)),
             #selector(BroserWindowController.selectNextFleet(_:)),
             #selector(BroserWindowController.selectPreviousFleet(_:)):
            
            return true
            
        case #selector(BroserWindowController.fleetListAbove(_:)):
            menuItem.state = (fleetViewPosition == .above ? .on : .off)
            return true
            
        case #selector(BroserWindowController.fleetListBelow(_:)):
            menuItem.state = (fleetViewPosition == .below ? .on : .off)
            return true
            
        case #selector(BroserWindowController.fleetListDivide(_:)):
            menuItem.state = (fleetViewPosition == .divided ? .on : .off)
            return true
            
        case #selector(BroserWindowController.fleetListSimple(_:)):
            menuItem.state = (fleetViewPosition == .oldStyle ? .on : .off)
            return true
            
        case #selector(BroserWindowController.reorderToDoubleLine(_:)):
            menuItem.state = (fleetViewController.shipOrder == .doubleLine ? .on : .off)
            return true
            
        case #selector(BroserWindowController.reorderToLeftToRight(_:)):
            menuItem.state = (fleetViewController.shipOrder == .leftToRight ? .on: .off)
            return true
            
        case #selector(BroserWindowController.clearQuestList(_:)):
            return true
            
        case #selector(BroserWindowController.showHideCombinedView(_:)):
            if isCombinedMode {
                
                menuItem.title = LocalizedStrings.hideCombinedView.string
                
            } else {
                
                menuItem.title = LocalizedStrings.showCombinedView.string
                
            }
            if fleetViewPosition == .oldStyle { return false }
            
            return true
            
        case #selector(BroserWindowController.toggleAnchorageSize(_:)):
            return true
            
        case #selector(BroserWindowController.changeSakutekiCalculator(_:)):
            return fleetViewController.validateMenuItem(menuItem)
            
        default:
            return false
        }
    }
}

extension BroserWindowController {
    
    private static let margin: CGFloat = 1.0
    private static let flashTopMargin: CGFloat = 4.0
    
    private func changeFleetViewForFleetViewPositionIfNeeded(position newPosition: FleetViewPosition) {
        
        if fleetViewPosition == newPosition { return }
        if fleetViewPosition != .oldStyle && newPosition != .oldStyle { return }
        if newPosition == .oldStyle && isCombinedMode { hideCombinedView() }
        
        let type: FleetViewType = (newPosition == .oldStyle) ? .minimumViewType : .detailViewType
        
        guard let newController = FleetViewController(viewType: type) else { return }
        
        newController.enableAnimation = true
        newController.shipOrder = fleetViewController.shipOrder
        replace(view: fleetViewController.view, with: newController)
        fleetViewController = newController
        fleetViewController.delegate = self
    }
    
    private func windowHeightForFleetViewPosition(position newPosition: FleetViewPosition) -> CGFloat {
        
        guard var contentHeight = window!.contentView?.frame.size.height else { return 0.0 }
        
        if fleetViewPosition == newPosition { return contentHeight }
        if fleetViewPosition == .oldStyle {
            
            contentHeight += FleetViewController.heightDifference
        }
        if newPosition == .oldStyle {
            
            contentHeight -= FleetViewController.heightDifference
        }
        
        return contentHeight
    }
    
    private func windowFrameForFleetViewPosition(position newPosition: FleetViewPosition) -> NSRect {
        
        var contentRect = window!.frame
        
        if fleetViewPosition == newPosition { return contentRect }
        if fleetViewPosition == .oldStyle {
            
            contentRect.size.height += FleetViewController.heightDifference
            contentRect.origin.y -= FleetViewController.heightDifference
        }
        if newPosition == .oldStyle {
            
            contentRect.size.height -= FleetViewController.heightDifference
            contentRect.origin.y += FleetViewController.heightDifference
        }
        
        return contentRect
    }
    
    private func flashFrameForFleetViewPosition(position newPosition: FleetViewPosition) -> NSRect {
        
        let contentHeight = windowHeightForFleetViewPosition(position: newPosition)
        
        var flashRect = gameViewController.view.frame
        var flashY: CGFloat
        switch newPosition {
        case .above:
            flashY = contentHeight - flashRect.height - fleetViewController.normalHeight
            
        case .below:
            flashY = contentHeight - flashRect.height
            
        case .divided:
            flashY = contentHeight - flashRect.height - fleetViewController.upsideHeight - BroserWindowController.margin
            
        case .oldStyle:
            flashY = contentHeight - flashRect.height - BroserWindowController.flashTopMargin
        }
        
        flashRect.origin.y = flashY
        
        return flashRect
    }
    
    private func fleetViewFrameForFleetViewPosition(position newPosition: FleetViewPosition) -> NSRect {
        
        let contentHeight = windowHeightForFleetViewPosition(position: newPosition)
        let flashRect = gameViewController.view.frame
        var fleetListRect = fleetViewController.view.frame
        
        var fleetViewHeight: CGFloat
        var fleetViewY: CGFloat
        
        switch newPosition {
        case .above:
            fleetViewHeight = fleetViewController.normalHeight
            fleetViewY = contentHeight - fleetViewHeight
            
        case .below:
            fleetViewHeight = fleetViewController.normalHeight
            fleetViewY = contentHeight - fleetViewHeight - flashRect.height - BroserWindowController.margin
            
        case .divided:
            fleetViewHeight = fleetViewController.normalHeight + flashRect.height + BroserWindowController.margin + BroserWindowController.margin
            fleetViewY = contentHeight - fleetViewHeight
            
        case .oldStyle:
            fleetViewHeight = FleetViewController.oldStyleFleetViewHeight
            fleetViewY = contentHeight - fleetViewHeight - flashRect.height - BroserWindowController.margin - BroserWindowController.flashTopMargin
        }
        
        fleetListRect.size.height = fleetViewHeight
        fleetListRect.origin.y = fleetViewY
        
        return fleetListRect
    }
    
    private func setFleetView(position newPosition: FleetViewPosition, animate: Bool) {
        
        guard let window = window else { return }
        
        changeFleetViewForFleetViewPositionIfNeeded(position: newPosition)
        let winFrame = windowFrameForFleetViewPosition(position: newPosition)
        let flashRect = flashFrameForFleetViewPosition(position: newPosition)
        let fleetListRect = fleetViewFrameForFleetViewPosition(position: newPosition)
        
        fleetViewPosition = newPosition
        UserDefaults.standard[.fleetViewPosition] = newPosition
        
        if animate {
            
            let winAnime = ViewAnimationAttributes(target: window, endFrame: winFrame)
            let flashAnime = ViewAnimationAttributes(target: gameViewController.view, endFrame: flashRect)
            let fleetAnime = ViewAnimationAttributes(target: fleetViewController.view, endFrame: fleetListRect)
            
            let anime = ViewAnimation(viewAnimations: [winAnime, flashAnime, fleetAnime])
            
            anime.start()
            
        } else {
            
            window.setFrame(winFrame, display: false)
            gameViewController.view.frame = flashRect
            fleetViewController.view.frame = fleetListRect
        }
    }
    
}

extension BroserWindowController: FleetViewControllerDelegate {
    
    func changeShowsExtShip(_ fleetViewController: FleetViewController, showsExtShip: Bool) {
        
        guard self.fleetViewController == fleetViewController else { return }
        
        if isExtShpMode && !showsExtShip {
            
            // hide
            let diffHeight = fleetViewController.shipViewSize.height
            
            var iFrame = informantionViewController.view.frame
            iFrame.origin.y -= diffHeight
            iFrame.size.height += diffHeight
            informantionViewController.view.animator().frame = iFrame
            
            var sFrame = stokerContainer.frame
            sFrame.origin.y -= diffHeight
            stokerContainer.animator().frame = sFrame
            
            isExtShpMode = false
            
        } else if !isExtShpMode && showsExtShip {
            
            //show
            let diffHeight = fleetViewController.shipViewSize.height
            
            var iFrame = informantionViewController.view.frame
            iFrame.origin.y += diffHeight
            iFrame.size.height -= diffHeight
            informantionViewController.view.animator().frame = iFrame
            
            var sFrame = stokerContainer.frame
            sFrame.origin.y += diffHeight
            stokerContainer.animator().frame = sFrame

            isExtShpMode = true
        }
    }
}

@available(OSX 10.12.2, *)
private var mainTouchBars: [Int: NSTouchBar] = [:]
@available(OSX 10.12.2, *)
private var shipTypeButtons: [Int: NSPopoverTouchBarItem] = [:]
@available(OSX 10.12.2, *)
private var shipTypeSegments: [Int: NSSegmentedControl] = [:]

@available(OSX 10.12.2, *)
extension BroserWindowController {
    
    @IBOutlet private var mainTouchBar: NSTouchBar! {
        
        get { return mainTouchBars[hashValue] }
        set { mainTouchBars[hashValue] = newValue }
    }
    
    @IBOutlet private var shipTypeButton: NSPopoverTouchBarItem! {
        
        get { return shipTypeButtons[hashValue] }
        set { shipTypeButtons[hashValue] = newValue }
    }
    
    @IBOutlet private var shipTypeSegment: NSSegmentedControl! {
        
        get { return shipTypeSegments[hashValue] }
        set { shipTypeSegments[hashValue] = newValue }
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        
        if let mainTouchBar = mainTouchBar { return mainTouchBar }
        
        Bundle.main.loadNibNamed(NSNib.Name("BroswerTouchBar"), owner: self, topLevelObjects: nil)
        
        shipTypeSegment.bind(.selectedIndex,
                             to: informantionViewController,
                             withKeyPath: #keyPath(InformationTabViewController.selectedShipType),
                             options: nil)
        
        informantionViewController.selectionDidChangeHandler = { [weak self] in
            
            guard let `self` = self else { return }
            
            self.shipTypeButton.dismissPopover(nil)
            
            guard let button = self.shipTypeButton.view as? NSButton else { return }
            button.isHidden = !self.informantionViewController.hasShipTypeSelector
            
            self.shipTypeSegment.bind(.selectedIndex,
                                      to: self.informantionViewController,
                                      withKeyPath: #keyPath(InformationTabViewController.selectedShipType),
                                      options: nil)
        }
        
        return mainTouchBar
    }
}
