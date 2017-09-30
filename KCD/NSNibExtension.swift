//
//  NSNibExtension.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/09/24.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

extension NSNib.Name {
    
    static func nibName<Subject>(for type: Subject) -> NSNib.Name {
        
        return NSNib.Name(String(describing: type))
    }
    
    static func nibName<Subject>(instanceOf instance: Subject) -> NSNib.Name {
        
        return NSNib.Name(String(describing: type(of: instance).self))
    }
}

protocol NibLoadable {
    
    static var nibName: NSNib.Name { get }
}

extension NibLoadable {
    
    static var nibName: NSNib.Name {
        
        return .nibName(for: self)
    }
}
