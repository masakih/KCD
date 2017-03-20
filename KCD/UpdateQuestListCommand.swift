//
//  UpdateQuestListCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class UpdateQuestListCommand: JSONCommand {
    override func execute() {
        let store = ServerDataStore.oneTimeEditor()
        parameter["api_quest_id"]
            .int
            .flatMap { store.quest(by: $0) }
            .map {
                $0.progress_flag = 0
                $0.state = 1
        }
    }
}
