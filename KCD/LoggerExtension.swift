//
//  LoggerExtension.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/10/28.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

extension Logger {
    
    static let shared = Logger(destination: ApplicationDirecrories.shared.support.appendingPathComponent("KCD.log"))
}
