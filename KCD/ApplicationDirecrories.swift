//
//  ApplicationDirecrories.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/08.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

struct ApplicationDirecrories {
    static let support: URL = {
        let url = FileManager
            .default
            .urls(for: .applicationSupportDirectory,
                  in: .userDomainMask).last ?? URL(fileURLWithPath: NSHomeDirectory())
        return url.appendingPathComponent("com.masakih.KCD")
    }()
    
    static let documents = FileManager
        .default
        .urls(for: .documentDirectory,
              in: .userDomainMask).last ?? URL(fileURLWithPath: NSHomeDirectory())
    static let pictures = FileManager
        .default
        .urls(for: .picturesDirectory,
              in: .userDomainMask).last ?? URL(fileURLWithPath: NSHomeDirectory())
}
