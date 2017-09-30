//
//  RepairListViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/25.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class RepairListViewController: MainTabVIewItemViewController {
    
    @objc let managedObjectContext = ServerDataStore.default.context
    @objc let fetchPredicate = NSPredicate(format: "NOT ndock_time = 0")
    
    override var nibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
}
