//
//  MainTabVIewItemViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/27.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

class MainTabVIewItemViewController: NSViewController {
    
    @objc dynamic var hasShipTypeSelector: Bool { return false }
    @objc dynamic var selectedShipType: ShipTabType = .all
}
