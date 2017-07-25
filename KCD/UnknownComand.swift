//
//  UnknownComand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class UnknownComand: JSONCommand {
    
    override func execute() {
        
        print("Unknown API command -> \(api)\nparameter -> \(parameter)\njson -> \(json)")
    }
}
