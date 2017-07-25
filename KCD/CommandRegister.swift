//
//  CommandRegister.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

enum JSONCommandError: Error {
    
    case CanNotFindCommand
}

final class CommandRegister {
    
    private static var registeredClasses: [JSONCommand.Type] = []
    
    class func register() {
        
        registerClass(Start2Command.self)
        registerClass(MemberNDockCommand.self)
        registerClass(MemberKDockCommand.self)
        registerClass(MemberDeckCommand.self)
        registerClass(MemberMaterialCommand.self)
        registerClass(MemberBasicCommand.self)
        registerClass(MemberShipCommand.self)
        registerClass(MemberSlotItemCommand.self)
        registerClass(MemberShip2Command.self)
        registerClass(MemberShip3Command.self)
        registerClass(MemberRequireInfoCommand.self)
        registerClass(CreateShipCommand.self)
        registerClass(DestroyItem2Command.self)
        registerClass(MapStartCommand.self)
        registerClass(BattleCommand.self)
        registerClass(GuardShelterCommand.self)
        registerClass(MapInfoCommand.self)
        registerClass(SetPlaneCommand.self)
        registerClass(SetActionCommand.self)
        registerClass(CreateSlotItemCommand.self)
        registerClass(GetShipCommand.self)
        registerClass(DestroyShipCommand.self)
        registerClass(PowerUpCommand.self)
        registerClass(RemodelSlotCommand.self)
        registerClass(ShipDeckCommand.self)
        registerClass(ChangeHenseiCommand.self)
        registerClass(KaisouLockCommand.self)
        registerClass(SlotResetCommand.self)
        registerClass(CombinedCommand.self)
        registerClass(SlotDepriveCommand.self)
        registerClass(QuestListCommand.self)
        registerClass(ClearItemGetComand.self)
        registerClass(NyukyoStartCommand.self)
        registerClass(HokyuChargeCommand.self)
        registerClass(NyukyoSpeedChangeCommand.self)
        registerClass(PortCommand.self)
        registerClass(AirCorpsSupplyCommand.self)
        registerClass(AirCorpsChangeNameCommand.self)
    }
    
    class func command(for response: APIResponse) -> JSONCommand {
        
        func concreteCommand(for response: APIResponse) -> JSONCommand {
            
            if !response.success {
                
                return FailedCommand(apiResponse: response)
                
            }
            
            if let c = registeredClasses.lazy.filter({ $0.canExecuteAPI(response.api) }).first {
                
                return c.init(apiResponse: response)
                
            }
            
            
            if IgnoreCommand.canExecuteAPI(response.api) {
                
                return IgnoreCommand(apiResponse: response)
                
            }
            
            return UnknownComand(apiResponse: response)
        }
        
        #if ENABLE_JSON_LOG
            return JSONViewCommand(apiResponse: response, command: concreteCommand(for: response))
        #else
            return concreteCommand(for: response)
        #endif
    }
    
    class func registerClass(_ commandClass: JSONCommand.Type) {
        
        if registeredClasses.contains(where: { $0 == commandClass }) { return }
        
        registeredClasses.append(commandClass)
    }
}
