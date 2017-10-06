//
//  QuestListViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/25.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class QuestListViewController: NSViewController {
    
    @objc let managedObjectContext = ServerDataStore.default.context
    @objc let sortDesciptors = [NSSortDescriptor(key: #keyPath(Quest.no), ascending: true)]
    
    override var nibName: NSNib.Name {
        
        return .nibName(instanceOf: self)
    }
}
