//
//  BroserWindowController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/31.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa


fileprivate extension Selector {
    static let reloadContent = #selector(BroserWindowController.reloadContent(_:))
    static let deleteCacheAndReload = #selector(BroserWindowController.deleteCacheAndReload(_:))
    static let clearQuestList = #selector(BroserWindowController.clearQuestList(_:))
    static let selectView = #selector(BroserWindowController.selectView(_:))
    static let changeMainTab = #selector(BroserWindowController.changeMainTab(_:))
    static let screenShot = #selector(BroserWindowController.screenShot(_:))
    static let toggleAnchorageSize = #selector(BroserWindowController.toggleAnchorageSize(_:))
    static let showHideCombinedView = #selector(BroserWindowController.showHideCombinedView(_:))
    static let fleetListAbove = #selector(BroserWindowController.fleetListAbove(_:))
    static let fleetListBelow = #selector(BroserWindowController.fleetListBelow(_:))
    static let fleetListDivide = #selector(BroserWindowController.fleetListDivide(_:))
    static let fleetListSimple = #selector(BroserWindowController.fleetListSimple(_:))
    static let reorderToDoubleLine = #selector(BroserWindowController.reorderToDoubleLine(_:))
    static let reorderToLeftToRight = #selector(BroserWindowController.reorderToLeftToRight(_:))
    static let selectNextFleet = #selector(BroserWindowController.selectNextFleet(_:))
    static let selectPreviousFleet = #selector(BroserWindowController.selectPreviousFleet(_:))
}

class BroserWindowController: NSWindowController {
    enum FleetViewPosition: Int {
        case above = 0
        case below = 1
        case divided = 2
        case oldStyle = 0xffffffff
    }
    
    class func keyPathsForValuesAffectingFlagShipName() -> Set<String> {
        return ["flagShipID"]
    }
    
    let managedObjectContext = ServerDataStore.default.context
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet weak var placeholder: NSView!
    @IBOutlet weak var combinedViewPlaceholder: NSView!
    @IBOutlet weak var deckPlaceholder: NSView!
    @IBOutlet weak var resourcePlaceholder: NSView!
    @IBOutlet weak var ancherageRepariTimerPlaceholder: NSView!
    @IBOutlet weak var informations: NSTabView!
    @IBOutlet var deckContoller: NSArrayController!
    
    override var windowNibName: String! {
        return "BroserWindowController"
    }
    var flagShipID: Int = 0
    var flagShipName: String? {
        return ServerDataStore.default.ship(byId: flagShipID)?.name
    }
    var changeMainTabHandler: ((Int) -> Void)?
    dynamic var selectedMainTabIndex: Int = 0 {
        didSet {
            changeMainTabHandler?(selectedMainTabIndex)
        }
    }
    
    fileprivate var gameViewController: GameViewController!
    fileprivate var fleetViewController: FleetViewController!
    fileprivate var tabViewItemViewControllers: [MainTabVIewItemViewController] = []
    fileprivate var ancherageRepariTimerViewController: AncherageRepairTimerViewController!
    private var resourceViewController: ResourceViewController!
    private var docksViewController: DocksViewController!
    private var shipViewController: ShipViewController!
    private var powerUpViewController: PowerUpSupportViewController!
    private var strengthedListViewController: StrengthenListViewController!
    private var repairListViewController: RepairListViewController!
    private var combinedViewController: CombileViewController!
    
    fileprivate var fleetViewPosition: FleetViewPosition = .above
    fileprivate var isCombinedMode = false
    
    // MARK: - Function
    override func windowDidLoad() {
        super.windowDidLoad()
    
        gameViewController = GameViewController()
        replace(placeholder, with: gameViewController)
        
        resourceViewController = ResourceViewController()
        replace(resourcePlaceholder, with: resourceViewController)
        
        ancherageRepariTimerViewController = AncherageRepairTimerViewController()
        replace(ancherageRepariTimerPlaceholder, with: ancherageRepariTimerViewController)
        if UserDefaults.standard.screenshotButtonSize == .small { toggleAnchorageSize(nil) }
        
        tabViewItemViewControllers = [
            DocksViewController(),
            ShipViewController(),
            PowerUpSupportViewController(),
            StrengthenListViewController(),
            RepairListViewController()
        ]
        tabViewItemViewControllers.enumerated().forEach {
            let _ = $0.element.view
            let item = informations.tabViewItem(at: $0.offset)
            item.viewController = $0.element
        }
        
        fleetViewController = FleetViewController(viewType: .detailViewType)
        replace(deckPlaceholder, with: fleetViewController)
        setFleetView(position: UserDefaults.standard.fleetViewPosition, animate: false)
        fleetViewController.enableAnimation = false
        fleetViewController.shipOrder = UserDefaults.standard.fleetViewShipOrder
        fleetViewController.enableAnimation = true
        
        bind("flagShipID", to: deckContoller, withKeyPath: "selection.ship_0", options: nil)
        
        NotificationCenter.default
            .addObserver(forName: .CombinedDidCange, object: nil, queue: nil) {
                guard UserDefaults.standard.autoCombinedView,
                    let type = $0.userInfo?[CombinedCommand.userInfoKey] as? CombineType
                    else { return }
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
        
        if UserDefaults.standard.lastHasCombinedView { showCombinedView() }
    }
    override func swipe(with event: NSEvent) {
        guard UserDefaults.standard.useSwipeChangeCombinedView else { return }
        if event.deltaX > 0 {
            showCombinedView()
        }
        if event.deltaX < 0 {
            hideCombinedView()
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        UserDefaults.standard.lastHasCombinedView = isCombinedMode
    }
    
    fileprivate func replace(_ view: NSView, with viewController: NSViewController) {
        viewController.view.frame = view.frame
        viewController.view.autoresizingMask = view.autoresizingMask
        self.window?.contentView?.replaceSubview(view, with: viewController.view)
    }
    fileprivate func showCombinedView() {
        if isCombinedMode { return }
        if fleetViewPosition == .oldStyle { return }
        isCombinedMode = true
        if combinedViewController == nil {
            combinedViewController = CombileViewController()
            combinedViewController.view.isHidden = true
            replace(combinedViewPlaceholder, with: combinedViewController)
        }
        
        var winFrame = window!.frame
        let incWid = combinedViewController.view.frame.maxX
        winFrame.size.width += incWid
        winFrame.origin.x -= incWid
        combinedViewController.view.isHidden = false
        window?.setFrame(winFrame, display: true, animate: true)
    }
    fileprivate func hideCombinedView() {
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
        informations.selectTabViewItem(at: number)
    }
    @IBAction func reloadContent(_ sender: AnyObject?) {
        gameViewController.reloadContent(sender)
    }
    @IBAction func deleteCacheAndReload(_ sender: AnyObject?) {
        gameViewController.deleteCacheAndReload(sender)
    }
    @IBAction func clearQuestList(_ sender: AnyObject?) {
        let store = ServerDataStore.oneTimeEditor()
        store.quests().forEach { store.delete($0) }
    }
    @IBAction func selectView(_ sender: AnyObject?) {
        guard let tag = sender?.tag else { return }
        showView(number: tag)
    }
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
        let newSize: NSControlSize = {
            if current == .regular {
                diff *= -1
                return .small
            }
            return .regular
        }()
        ancherageRepariTimerViewController.controlSize = newSize
        
        var frame = informations.frame
        frame.size.height -= diff
        frame.origin.y += diff
        informations.frame = frame
        
        UserDefaults.standard.screenshotButtonSize = newSize
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
        UserDefaults.standard.fleetViewShipOrder = .doubleLine
    }
    @IBAction func reorderToLeftToRight(_ sender: AnyObject?) {
        fleetViewController.shipOrder = .leftToRight
        UserDefaults.standard.fleetViewShipOrder = .leftToRight
    }
    @IBAction func selectNextFleet(_ sender: AnyObject?) {
        fleetViewController.selectNextFleet(sender)
    }
    @IBAction func selectPreviousFleet(_ sender: AnyObject?) {
        fleetViewController.selectPreviousFleet(sender)
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let action: Selector = menuItem.action else { return false }
        switch action {
        case Selector.reloadContent, Selector.screenShot, Selector.deleteCacheAndReload:
            return gameViewController.validateMenuItem(menuItem)
        case Selector.selectView, Selector.selectNextFleet, Selector.selectPreviousFleet:
            return true
        case Selector.fleetListAbove:
            menuItem.state = fleetViewPosition == .above ? NSOnState : NSOffState
            return true
        case Selector.fleetListBelow:
            menuItem.state = fleetViewPosition == .below ? NSOnState : NSOffState
            return true
        case Selector.fleetListDivide:
            menuItem.state = fleetViewPosition == .divided ? NSOnState : NSOffState
            return true
        case Selector.fleetListSimple:
            menuItem.state = fleetViewPosition == .oldStyle ? NSOnState : NSOffState
            return true
        case Selector.reorderToDoubleLine:
            menuItem.state = fleetViewController.shipOrder == .doubleLine ? NSOnState : NSOffState
            return true
        case Selector.reorderToLeftToRight:
            menuItem.state = fleetViewController.shipOrder == .leftToRight ? NSOnState: NSOffState
            return true
        case Selector.clearQuestList:
            return true
        case Selector.showHideCombinedView:
            if isCombinedMode {
                menuItem.title = NSLocalizedString("Hide Combined View", comment: "View menu, hide combined view")
            } else {
                menuItem.title = NSLocalizedString("Show Combined View", comment: "View menu, show combined view")
            }
            if fleetViewPosition == .oldStyle { return false }
            return true
        case Selector.toggleAnchorageSize:
            return true
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
        replace(fleetViewController.view, with: newController)
        fleetViewController = newController
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
            flashY = contentHeight
                - flashRect.height
                - fleetViewController.upsideHeight
                - BroserWindowController.margin
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
            fleetViewY = contentHeight
                - fleetViewHeight
                - flashRect.height
                - BroserWindowController.margin
        case .divided:
            fleetViewHeight = fleetViewController.normalHeight
                + flashRect.height
                + BroserWindowController.margin
                + BroserWindowController.margin
            fleetViewY = contentHeight - fleetViewHeight
        case .oldStyle:
            fleetViewHeight = FleetViewController.oldStyleFleetViewHeight
            fleetViewY = contentHeight
                - fleetViewHeight
                - flashRect.height
                - BroserWindowController.margin
                - BroserWindowController.flashTopMargin
        }
        fleetListRect.size.height = fleetViewHeight
        fleetListRect.origin.y = fleetViewY
        return fleetListRect
    }
    fileprivate func setFleetView(position newPosition: FleetViewPosition, animate: Bool) {
        changeFleetViewForFleetViewPositionIfNeeded(position: newPosition)
        let winFrame = windowFrameForFleetViewPosition(position: newPosition)
        let flashRect = flashFrameForFleetViewPosition(position: newPosition)
        let fleetListRect = fleetViewFrameForFleetViewPosition(position: newPosition)
        
        fleetViewPosition = newPosition
        UserDefaults.standard.fleetViewPosition = newPosition
        
        if animate {
            let winAnime: [String: Any]  = [ NSViewAnimationTargetKey: window!,
                             NSViewAnimationEndFrameKey: NSValue(rect: winFrame) ]
            let flashAnime: [String: Any] = [ NSViewAnimationTargetKey: gameViewController.view,
                               NSViewAnimationEndFrameKey: NSValue(rect: flashRect) ]
            let fleetAnime: [String: Any] = [ NSViewAnimationTargetKey: fleetViewController.view,
                               NSViewAnimationEndFrameKey: NSValue(rect: fleetListRect) ]
            let anime = NSViewAnimation(viewAnimations: [winAnime, flashAnime, fleetAnime])
            anime.start()
        } else {
            window!.setFrame(winFrame, display: false)
            gameViewController.view.frame = flashRect
            fleetViewController.view.frame = fleetListRect
        }
    }
    
}

@available(OSX 10.12.2, *)
fileprivate var mainTouchBars: [Int: NSTouchBar] = [:]
@available(OSX 10.12.2, *)
fileprivate var shipTypeButtons: [Int: NSPopoverTouchBarItem] = [:]
@available(OSX 10.12.2, *)
fileprivate var shipTypeSegments: [Int: NSSegmentedControl] = [:]

@available(OSX 10.12.2, *)
extension BroserWindowController {
    @IBOutlet var mainTouchBar: NSTouchBar! {
        get { return mainTouchBars[hashValue] }
        set { mainTouchBars[hashValue] = newValue }
    }
    @IBOutlet var shipTypeButton: NSPopoverTouchBarItem! {
        get { return shipTypeButtons[hashValue] }
        set { shipTypeButtons[hashValue] = newValue }
    }
    @IBOutlet var shipTypeSegment: NSSegmentedControl! {
        get { return shipTypeSegments[hashValue] }
        set { shipTypeSegments[hashValue] = newValue }
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        if let mainTouchBar = mainTouchBar { return mainTouchBar }
        var array: NSArray = []
        Bundle.main.loadNibNamed("BroswerTouchBar", owner: self, topLevelObjects: &array)
        
        shipTypeSegment.bind(NSSelectedIndexBinding,
                             to: tabViewItemViewControllers[0],
                             withKeyPath: "selectedShipType",
                             options: nil)
        let o = selectedMainTabIndex
        selectedMainTabIndex = o
        
        changeMainTabHandler = { [weak self] in
            guard let `self` = self else { return }
            self.shipTypeButton.dismissPopover(nil)
            self.shipTypeSegment.unbind(NSSelectedIndexBinding)
            guard let button = self.shipTypeButton.view as? NSButton else { return }
            let vc = self.tabViewItemViewControllers[$0]
            button.isHidden = !vc.hasShipTypeSelector
            self.shipTypeSegment.bind(NSSelectedIndexBinding,
                                      to: vc,
                                      withKeyPath: "selectedShipType",
                                      options: nil)
        }
        return mainTouchBar
    }
}
