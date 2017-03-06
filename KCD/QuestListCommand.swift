//
//  QuestListCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class QuestListCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_get_member/questlist" { return true }
        return false
    }
    override func execute() {
        // 左のタブがAllじゃない時は無視する
        guard let tab = arguments["api_tab_id"].flatMap({ Int($0) }),
            tab == 0
            else { return }
        
        let j = json as NSDictionary
        guard let data = j.value(forKeyPath: dataKey) as? [String: Any],
            let questList = data["api_list"] as? [Any],
            let ql0 = questList.first as? [String: Any],
            let ql0No = ql0["api_no"] as? Int,
            let pageCount = data["api_page_count"] as? Int,
            let page = data["api_disp_page"] as? Int
            else { return print("data is wrong") }
        
        let store = ServerDataStore.oneTimeEditor()
        
        // 範囲内の任務をいったん遂行中からはずす
        let qlm = questList.last as? [String: Any]
        let qlmNo = qlm?["api_no"] as? Int ?? 9999
        let minNo = (page == 1) ? 0 : ql0No
        let maxNo = (page == pageCount) ? 9999 : qlmNo
        store.quests(in: minNo...maxNo).forEach { $0.state = 1 }
        
        // 新しいデータ投入
        let quests = store.sortedQuestByNo()
        questList.forEach {
            guard let questData = $0 as? [String: Any],
                let no = questData["api_no"] as? Int
            else { return }
            let t = quests.binarySearch { $0.no ==? no }
            guard let new = t ?? store.createQuest()
                else { return print("Can not create Quest") }
            new.bonus_flag = questData["api_bonus_flag"] as? Bool ?? false
            new.category = questData["api_category"] as? Int ?? 0
            new.detail = questData["api_detail"] as? String ?? ""
//            new.get_material_0 = questData["api_get_material_0"] as? Int ?? 0
//            new.get_material_1 = questData["api_get_material_1"] as? Int ?? 0
//            new.get_material_2 = questData["api_get_material_2"] as? Int ?? 0
//            new.get_material_3 = questData["api_get_material_3"] as? Int ?? 0
            new.invalid_flag = questData["api_invalid_flag"] as? Int ?? 0
            new.no = questData["api_no"] as? Int ?? 0
            new.progress_flag = questData["api_progress_flag"] as? Int ?? 0
            new.state = questData["api_state"] as? Int ?? 0
            new.title = questData["api_title"] as? String ?? ""
            new.type = questData["api_type"] as? Int ?? 0
        }
    }
}
