//
//  DummyShipCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/15.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

/**
 * 出撃中にドロップした艦をマスクした上で入居数に反映させるためのダミーデータの生成と削除を行う
 **/
class DummyShipCommand: JSONCommand {
    private static var needsEnterDummy = false
    
    override func execute() {
        if api == "/kcsapi/api_req_sortie/battleresult" { checkGetShip() }
        if api == "/kcsapi/api_get_member/ship_deck" { enterDummy() }
        if api == "/kcsapi/api_port/port" { removeDummy() }
    }
    
    private func checkGetShip() {
        DummyShipCommand.needsEnterDummy = data["api_get_ship"].exists()
    }
    private func enterDummy() {
        guard DummyShipCommand.needsEnterDummy else { return }
        let store = ServerDataStore.oneTimeEditor()
        store.createShip()?.id = -2
        DummyShipCommand.needsEnterDummy = false
    }
    private func removeDummy() {
        let store = ServerDataStore.oneTimeEditor()
        store.ships(by: -2).forEach { store.delete($0) }
        DummyShipCommand.needsEnterDummy = false
    }
}
