//
//  NSUserInterfaceItemIdentifierExtension.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/09/24.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension NSUserInterfaceItemIdentifier {
    
    static func identifier<Subject>(for type: Subject) -> NSUserInterfaceItemIdentifier {
        
        return NSUserInterfaceItemIdentifier(rawValue: String(describing: type))
    }
}

protocol UserInterfaceItemIdentifierProvider {
    
    static var itemIdentifier: NSUserInterfaceItemIdentifier { get }
}

extension UserInterfaceItemIdentifierProvider {
    
    static var itemIdentifier: NSUserInterfaceItemIdentifier {
        
        return .identifier(for: self)
    }
}
