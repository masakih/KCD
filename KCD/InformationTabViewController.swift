//
//  InformationTabViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2018/02/04.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Cocoa

@objc
enum ShipTabType: Int {
    
    case all = 0
    
    case destroyer = 1
    
    case lightCruiser = 2
    
    case heavyCruiser = 3
    
    case aircraftCarrier = 4
    
    case battleShip = 5
    
    case submarine = 6
    
    case other = 7
}

private let shipTypeCategories: [[Int]] = [
    [0],    // dummy
    [2],    // destoryer
    [3, 4], // leght cruiser
    [5, 6], // heavy crusier
    [7, 11, 16, 18],    // aircraft carrier
    [8, 9, 10, 12], // battle ship
    [13, 14],   // submarine
    [1, 15, 17, 19, 20, 21, 22]
]

func shipTypePredicte(for type: ShipTabType) -> NSPredicate? {
    
    switch type {
        
    case .all:
        
        return nil
        
    case .destroyer, .lightCruiser, .heavyCruiser,
         .aircraftCarrier, .battleShip, .submarine:
        
        return NSPredicate(#keyPath(Ship.master_ship.stype.id), valuesIn: shipTypeCategories[type.rawValue])
        
    case .other:
        let omitTypes = shipTypeCategories
            .dropLast()
            .dropFirst()
            .flatMap { $0 }
        
        return .not(NSPredicate(#keyPath(Ship.master_ship.stype.id), valuesIn: omitTypes))
        
    }
}

class InformationTabViewController: NSViewController {
    
    @objc private(set) dynamic var hasShipTypeSelector: Bool = false
    @objc private(set) dynamic var selectedShipType: ShipTabType = .all {
        
        didSet {
            guard case 0..<tabViewItemViewControllers.count = selectionIndex else {
                
                return
            }
            tabViewItemViewControllers[selectionIndex].selectedShipType = selectedShipType
        }
    }
    @objc dynamic var selectionIndex: Int = 0 {
        
        willSet {
            
            unbind(NSBindingName("selectedShipType"))
        }

        didSet {
            
            guard case 0..<tabViewItemViewControllers.count = selectionIndex else {
                
                return
            }
            hasShipTypeSelector = tabViewItemViewControllers[selectionIndex].hasShipTypeSelector

            bind(NSBindingName("selectedShipType"),
                 to: tabViewItemViewControllers[selectionIndex],
                 withKeyPath: #keyPath(MainTabVIewItemViewController.selectedShipType))
            
            selectionDidChangeHandler?()
        }
    }
    
    @IBOutlet private var informations: NSTabView!
    
    var selectionDidChangeHandler: (() -> Void)?
    
    private var tabViewItemViewControllers: [MainTabVIewItemViewController] = []
    
    override var nibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tabViewItemViewControllers = [
            DocksViewController(),
            ShipViewController(),
            PowerUpSupportViewController(),
            StrengthenListViewController(),
            RepairListViewController()
        ]
        tabViewItemViewControllers.enumerated().forEach {
            
            _ = $0.element.view
            let item = informations.tabViewItem(at: $0.offset)
            item.viewController = $0.element
        }
    }
}
