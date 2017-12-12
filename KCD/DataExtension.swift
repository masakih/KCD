//
//  DataExtension.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/12/12.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

extension Data {
    
    var utf8String: String? { return String(data: self, encoding: .utf8) }
}
