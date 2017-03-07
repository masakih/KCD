//
//  CreateShipCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/11.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class CreateShipCommand: JSONCommand {
    override class func canExecuteAPI(_ api: String) -> Bool {
        if api == "/kcsapi/api_req_kousyou/createship" { return true }
        return false
    }
    override func execute() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.afterExecute()
        }
    }
    private func afterExecute() {
        guard let dockId = arguments["api_kdock_id"].flatMap({ Int($0) })
            else { return print("api_kdock_id is wrong") }
        let store = ServerDataStore.default
        guard let kenzoDock = store.kenzoDock(byDockId: dockId),
            let flagShip = store.deck(byId: 1)
                .flatMap({ store.ship(byId: $0.ship_0) }),
            let basic = store.basic()
            else { return print("CreateShipCommand: CoreData is wrong") }
        
        let localStore = LocalDataStore.oneTimeEditor()
        guard let newMark = localStore.kenzoMark(byDockId: dockId) ?? localStore.createKenzoMark()
            else { return print("Can not create KenzoMark") }
        
        newMark.fuel = kenzoDock.item1
        newMark.bull = kenzoDock.item2
        newMark.steel = kenzoDock.item3
        newMark.bauxite = kenzoDock.item4
        newMark.kaihatusizai = kenzoDock.item5
        newMark.created_ship_id = kenzoDock.created_ship_id
        newMark.flagShipName = flagShip.name
        newMark.flagShipLv = flagShip.lv
        newMark.commanderLv = basic.level
        newMark.kDockId = dockId
    }
}