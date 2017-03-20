//
//  FailedCommand.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class FailedCommand: JSONCommand {
    override func execute() {
        print("Fail API comand -> \(api)\nparameter -> \(parameter)\njson -> \(json)")
    }
}
