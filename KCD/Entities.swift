//
//  Entities.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/10/13.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Doutaku

// MARK: - KCD model
extension AirBase: Entity {}
extension AirBasePlaneInfo: Entity {}
extension Basic: Entity {}
extension Deck: Entity {}
extension KenzoDock: Entity {}
extension MasterFurniture: Entity {}
extension MasterMapArea: Entity {}
extension MasterMapInfo: Entity {}
extension MasterMission: Entity {}
extension MasterShip: Entity {}
extension MasterSlotItem: Entity {}
extension MasterSType: Entity {}
extension MasterSlotItemEquipType: Entity {}
extension MasterUseItem: Entity {}
extension Material: Entity {}
extension NyukyoDock: Entity {}
extension Ship: Entity {}
extension SlotItem: Entity {}
extension Quest: Entity {}

// MARK: - LocalData model
extension DropShipHistory: Entity {}
extension HiddenDropShipHistory: Entity {}
extension KaihatuHistory: Entity {}
extension KenzoHistory: Entity {}
extension KenzoMark: Entity {}

// MARK: - Temporay model
extension Battle: Entity {}
extension Damage: Entity {}
extension GuardEscaped: Entity {}

// MARK: - Bookmark model
extension Bookmark: Entity {}

// MARK: - ResourceHistory model
extension Resource: Entity {}
