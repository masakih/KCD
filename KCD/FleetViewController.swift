//
//  FleetViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/27.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

enum FleetViewType: Int {
    
    case detailViewType = 0
    case minimumViewType = 1
    case miniVierticalType = 2
}

fileprivate var shipKeysContext: Int = 0
fileprivate var shipsContext: Int = 0

final class FleetViewController: NSViewController {
    
    enum ShipOrder: Int {
        
        case doubleLine = 0
        case leftToRight = 1
    }
    
    enum SakutekiType: Int {
        
        case adding = 0
        
        case formula33 = 100
        case formula33Parameter1 = 101
        case formula33Parameter3 = 103
        case formula33Parameter4 = 104
        
    }
    
    enum SakutekiCalclationSterategy: Int {
        
        case total
        case formula33
    }
    
    static let oldStyleFleetViewHeight: CGFloat = 128.0
    static let detailViewHeight: CGFloat = 288.0
    static let heightDifference: CGFloat = detailViewHeight - oldStyleFleetViewHeight
    
    private static let maxFleetNumber: Int = 4
    
    fileprivate let details: [ShipDetailViewController]
    private let shipKeys = ["ship_0", "ship_1", "ship_2", "ship_3", "ship_4", "ship_5"]
    private let type: FleetViewType
    private let fleetController = NSObjectController()
    private let shipObserveKeys = ["seiku", "lv", "equippedItem"]
    
    init?(viewType: FleetViewType) {
        
        type = viewType
        
        let shipiewType: ShipDetailViewType = {
            
            switch viewType {
            case .detailViewType: return .full
            case .minimumViewType: return .medium
            case .miniVierticalType: return .minimum
            }
        }()
        details = (1...6).map {
            
            guard let res = ShipDetailViewController(type: shipiewType)
                else { fatalError("Can not create ShipDetailViewController") }
            
            res.title = "\($0)"
            
            return res
        }
        
        let nibName: String = {
            switch viewType {
            case .detailViewType: return "FleetViewController"
            case .minimumViewType: return "FleetMinimumViewController"
            case .miniVierticalType: return "VerticalFleetViewController"
            }
        }()
        
        super.init(nibName: nibName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet weak var placeholder01: NSView!
    @IBOutlet weak var placeholder02: NSView!
    @IBOutlet weak var placeholder03: NSView!
    @IBOutlet weak var placeholder04: NSView!
    @IBOutlet weak var placeholder05: NSView!
    @IBOutlet weak var placeholder06: NSView!
    
    dynamic var fleetNumber: Int = 1 {
        
        didSet {
            ServerDataStore.default
                .deck(by: fleetNumber)
                .map { fleet = $0 }
        }
    }
    
    dynamic var fleet: Deck? {
        
        get { return representedObject as? Deck }
        set {
            representedObject = newValue
            title = newValue?.name
            setupShips()
        }
    }
    
    var enableAnimation: Bool = false
    
    var shipOrder: FleetViewController.ShipOrder = .doubleLine {
        
        willSet {
            if shipOrder == newValue { return }
            
            switch newValue {
            case .doubleLine: reorderShipToDoubleLine()
            case .leftToRight: reorderShipToLeftToRight()
            }
        }
    }
    
    var canDivide: Bool { return type == .detailViewType }
    
    var normalHeight: CGFloat {
        
        switch type {
        case .detailViewType: return FleetViewController.detailViewHeight
        case .minimumViewType: return FleetViewController.oldStyleFleetViewHeight
        case .miniVierticalType: return 0.0
        }
    }
    
    var upsideHeight: CGFloat {
        
        switch type {
        case .detailViewType: return 159.0
        case .minimumViewType: return FleetViewController.oldStyleFleetViewHeight
        case .miniVierticalType: return 0.0
        }
    }
    
    var sakutekiCalculator: SakutekiCalculator = SimpleCalculator() {
        
        didSet {
            switch sakutekiCalculator {
            case _ as SimpleCalculator:
                UserDefaults.standard[.sakutekiCalclationSterategy] = .total
                
            case let f as Formula33:
                UserDefaults.standard[.sakutekiCalclationSterategy] = .formula33
                UserDefaults.standard[.formula33Factor] = Double(f.condition)
                
            default: ()
            }
        }
    }
    
    var totalSakuteki: Double { return sakutekiCalculator.calculate(ships) }
    var totalSeiku: Int { return ships.reduce(0) { $0 + $1.seiku } }
    var totalCalclatedSeiku: Int { return ships.reduce(0) { $0 + $1.totalSeiku } }
    var totalLevel: Int { return ships.reduce(0) { $0 + $1.lv } }
    var totalDrums: Int { return ships.reduce(0) { $0 + $1.totalDrums } }
    
    
    fileprivate var ships: [Ship] = [] {
        
        willSet {
            ships.forEach { ship in
                
                shipObserveKeys.forEach {
                    
                    ship.removeObserver(self, forKeyPath: $0)
                }
            }
        }
        didSet {
            ships.forEach { ship in
                
                shipObserveKeys.forEach {
                    
                    ship.addObserver(self, forKeyPath: $0, context: &shipsContext)
                }
            }
        }
    }
    
    private(set) var anchorageRepair = AnchorageRepairManager.default
    
    dynamic fileprivate(set) var repairTime: NSNumber?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        switch UserDefaults.standard[.sakutekiCalclationSterategy] {
        case .total:
            sakutekiCalculator = SimpleCalculator()
            
        case .formula33:
            let factor = UserDefaults.standard[.formula33Factor]
            sakutekiCalculator = Formula33(Int(factor))
        }
        
        fleetController.bind("content", to:self, withKeyPath:#keyPath(fleet), options:nil)
        fleetController.addObserver(self, forKeyPath:"selection.name", context:nil)
        shipKeys.forEach {
            
            let keyPath = "selection.\($0)"
            fleetController.addObserver(self, forKeyPath:keyPath, context:&shipKeysContext)
        }
        
        buildAnchorageRepairHolder()
        
        [placeholder01, placeholder02, placeholder03,
         placeholder04, placeholder05, placeholder06]
            .enumerated()
            .forEach {
                
                guard let view = $0.element else { return }
                
                let detail = details[$0.offset]
                detail.view.frame = view.frame
                detail.view.autoresizingMask = view.autoresizingMask
                self.view.replaceSubview(view, with: detail.view)
        }
        fleetNumber = 1
        
        NotificationCenter.default
            .addObserver(forName: .DidPrepareFleet, object: nil, queue: nil) { [weak self] _ in
                
                guard let `self` = self else { return }
                
                self.notifyChangeValue(forKey: #keyPath(fleetNumber))
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        
        if keyPath == "selection.name" {
            
            title = fleet?.name
            
            return
        }
        
        if context == &shipKeysContext {
            
            setupShips()
            
            return
        }
        
        if let keyPath = keyPath {
            
            if context == &shipsContext {
                
                switch keyPath {
                case "equippedItem":
                    notifyChangeValue(forKey: #keyPath(totalSakuteki))
                    notifyChangeValue(forKey: #keyPath(totalDrums))
                    notifyChangeValue(forKey: #keyPath(totalCalclatedSeiku))
                    
                case "seiku":
                    notifyChangeValue(forKey: #keyPath(totalSeiku))
                    notifyChangeValue(forKey: #keyPath(totalCalclatedSeiku))
                    
                case "lv":
                    notifyChangeValue(forKey: #keyPath(totalLevel))
                    
                default: break
                }
                
                return
            }
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    @IBAction func selectNextFleet(_ sender: AnyObject?) {
        
        let next = fleetNumber + 1
        fleetNumber = next <= FleetViewController.maxFleetNumber ? next : 1
    }
    
    @IBAction func selectPreviousFleet(_ sender: AnyObject?) {
        
        let prev = fleetNumber - 1
        fleetNumber = prev > 0 ? prev : 4
    }
    
    @IBAction func changeSakutekiCalculator(_ sender: Any?) {
        
        guard let menuItem = sender as? NSMenuItem
            else { return }
        
        switch menuItem.tag {
        case 0:
            sakutekiCalculator = SimpleCalculator()
            
        case 101...199:
            sakutekiCalculator = Formula33(menuItem.tag - 100)
            
        case 100:
            askCalcutaionTurnPoint()
            
        default: return
        }
        
        notifyChangeValue(forKey: #keyPath(totalSakuteki))
    }
    
    private func askCalcutaionTurnPoint() {
        
        guard let window = self.view.window else { return }
        
        let current = (sakutekiCalculator as? Formula33)?.condition ?? 1
        
        let wc = CalculateConditionPanelController()
        wc.condition = Double(current)
        wc.beginModal(for: window) {
            
            self.sakutekiCalculator = Formula33(Int($0))
            
            self.notifyChangeValue(forKey: #keyPath(totalSakuteki))
        }
    }
    
    private func setupShips() {
        
        let array: [Ship?] = (0..<6).map { fleet?[$0] }
        zip(details, array).forEach { $0.0.ship = $0.1 }
        ships = array.flatMap { $0 }
        
        [#keyPath(totalSakuteki), #keyPath(totalSeiku), #keyPath(totalCalclatedSeiku),
         #keyPath(totalLevel), #keyPath(totalDrums), #keyPath(repairable)]
            .forEach { notifyChangeValue(forKey: $0) }
    }
}

extension FleetViewController {
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        
        guard let action = menuItem.action
            else { return false }
        
        switch action {
            
        case #selector(changeSakutekiCalculator(_:)):
            
            if let _ = sakutekiCalculator as? SimpleCalculator {
                
                menuItem.state = menuItem.tag == 0 ? NSOnState : NSOffState
                
                return true
                
            } else if let sakuObj = sakutekiCalculator as? Formula33 {
                
                let cond = 100 + sakuObj.condition
                
                menuItem.state = menuItem.tag == cond ? NSOnState : NSOffState
                
                return true
            }
            
        default: ()
        }
        
        return false
    }
}

extension FleetViewController {
    
    private func reorder(order: [Int]) {
        
        guard order.count == 6 else {
            print("FleetViewController: order count is not 6.")
            return
        }
        
        let views: [NSView] = details.map { $0.view }
        let options: [NSAutoresizingMaskOptions] = views.map { $0.autoresizingMask }
        let reorderedOptions = order.map { options[$0] }
        zip(views, reorderedOptions).forEach { $0.0.autoresizingMask = $0.1 }
        
        let frames: [NSRect] = views.map { $0.frame }
        let reorderedFrames = order.map { frames[$0] }
        zip(views, reorderedFrames)
            .forEach { $0.0.setFrame($0.1, animate: enableAnimation) }
    }
    
    fileprivate func reorderShipToDoubleLine() {
        
        reorder(order: [0, 3, 1, 4, 2, 5])
    }
    
    fileprivate func reorderShipToLeftToRight() {
        
        reorder(order: [0, 2, 4, 1, 3, 5])
    }
}

extension FleetViewController {
    
    func buildAnchorageRepairHolder() {
        
        AppDelegate.shared.addCounterUpdate { [weak self] in
            
            guard let `self` = self else { return }
            
            self.repairTime = self.calcRepairTime()
        }
    }
    
    private func calcRepairTime() -> NSNumber? {
        
        let time = anchorageRepair.repairTime
        let complete = time.timeIntervalSince1970
        let now = Date(timeIntervalSinceNow: 0.0)
        let diff = complete - now.timeIntervalSince1970
        
        return NSNumber(value: diff + 20.0 * 60)
    }
    
    private var repairShipIds: [Int] { return [19] }
    
    dynamic var repairable: Bool {
        
        guard let flagShip = fleet?[0]
            else { return false }
        
        return repairShipIds.contains(flagShip.master_ship.stype.id)
    }
}
