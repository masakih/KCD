//
//  QuestListCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class QuestListCommand: JSONCommand {
    
    override class func canExecuteAPI(_ api: API) -> Bool {
        
        return api.endpoint == .questList
    }
    
    override func execute() {
        
        // 左のタブがAllじゃない時は無視する
        guard let tab = parameter["api_tab_id"].int, tab == 0 else { return }
        
        let questList = data["api_list"]
        let questNumberList = questList.array?.flatMap { $0["api_no"].int }
        
        guard let firstQuestNumber = questNumberList?.first,
            let pageCount = data["api_page_count"].int,
            let page = data["api_disp_page"].int else {
                
                return Logger.shared.log("data is wrong")
        }
        
        let store = ServerDataStore.oneTimeEditor()
        
        // 範囲内の任務をいったん遂行中からはずす
        let lastQuestNumber = questNumberList?.last ?? 9999
        let minNo = (page == 1) ? 0 : firstQuestNumber
        let maxNo = (page == pageCount) ? 9999 : lastQuestNumber
        store.sync { store.quests(in: minNo...maxNo).forEach { $0.state = 1 } }
        
        // 新しいデータ投入
        let quests = store.sync { store.sortedQuestByNo() }
        questList.forEach { _, quest in
            
            guard let no = quest["api_no"].int else { return }
            
            let t = store.sync { quests.binarySearch { $0.no ==? no } }
            
            guard let new = t ?? store.sync(execute: { store.createQuest() }) else {
                
                return Logger.shared.log("Can not create Quest")
            }
            
            store.sync {
                new.bonus_flag = quest["api_bonus_flag"].int.map { $0 != 0 } ?? false
                new.category = quest["api_category"].int ?? 0
                new.detail = quest["api_detail"].string ?? ""
//                new.get_material_0 = questData["api_get_material_0"] as? Int ?? 0
//                new.get_material_1 = questData["api_get_material_1"] as? Int ?? 0
//                new.get_material_2 = questData["api_get_material_2"] as? Int ?? 0
//                new.get_material_3 = questData["api_get_material_3"] as? Int ?? 0
                new.invalid_flag = quest["api_invalid_flag"].int ?? 0
                new.no = quest["api_no"].int ?? 0
                new.progress_flag = quest["api_progress_flag"].int ?? 0
                new.state = quest["api_state"].int ?? 0
                new.title = quest["api_title"].string ?? ""
                new.type = quest["api_type"].int ?? 0
            }
        }
    }
}
