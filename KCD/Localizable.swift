//
//  Localizable.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/10/01.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

protocol Localizable {
    
    var key: String { get }
    var table: String? { get }
    var comment: String { get }
    
    var string: String { get }
}

extension Localizable {
    
    var string: String {
        
        return NSLocalizedString(key, tableName: table, bundle: .main, comment: comment)
    }
}

struct LocalizedString: Localizable {
    
    let key: String
    let table: String? = nil
    let comment: String
    
    
    init(_ string: String, comment: String) {
        self.key = string
        self.comment = comment
    }
}

struct LocalizedStringFromTable: Localizable {
    
    let key: String
    let table: String?
    let comment: String
    
    
    init(_ string: String, tableName: String, comment: String) {
        self.key = string
        self.table = tableName
        self.comment = comment
    }
}
