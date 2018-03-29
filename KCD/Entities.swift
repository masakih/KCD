//
//  Entities.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/10/13.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Doutaku

// MARK: - KCD model
extension AirBase: EntityProvider {}
extension AirBasePlaneInfo: EntityProvider {}
extension Basic: EntityProvider {}
extension Deck: EntityProvider {}
extension KenzoDock: EntityProvider {}
extension MasterFurniture: EntityProvider {}
extension MasterMapArea: EntityProvider {}
extension MasterMapInfo: EntityProvider {}
extension MasterMission: EntityProvider {}
extension MasterShip: EntityProvider {}
extension MasterSlotItem: EntityProvider {}
extension MasterSType: EntityProvider {}
extension MasterSlotItemEquipType: EntityProvider {}
extension MasterUseItem: EntityProvider {}
extension Material: EntityProvider {}
extension NyukyoDock: EntityProvider {}
extension Ship: EntityProvider {}
extension SlotItem: EntityProvider {}
extension Quest: EntityProvider {}

// MARK: - LocalData model
extension DropShipHistory: EntityProvider {}
extension HiddenDropShipHistory: EntityProvider {}
extension KaihatuHistory: EntityProvider {}
extension KenzoHistory: EntityProvider {}
extension KenzoMark: EntityProvider {}

// MARK: - Temporay model
extension Battle: EntityProvider {}
extension Damage: EntityProvider {}
extension GuardEscaped: EntityProvider {}

// MARK: - Bookmark model
extension Bookmark: EntityProvider {}

// MARK: - ResourceHistory model
extension Resource: EntityProvider {}
