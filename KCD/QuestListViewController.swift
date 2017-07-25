//
//  QuestListViewController.swift
//  KCD
//
//  Created by Hori,Masaki on 2016/12/25.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class QuestListViewController: NSViewController {
    
    let managedObjectContext = ServerDataStore.default.context
    let sortDesciptors = [NSSortDescriptor(key: "no", ascending: true)]
    
    override var nibName: String! {
        
        return "QuestListViewController"
    }
}
