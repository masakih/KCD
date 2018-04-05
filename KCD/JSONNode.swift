//
//  JSONNode.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import SwiftyJSON

class JSONNode: NSObject, NSCoding, NSCopying {
    
    class func nodeWithJSON(_ json: JSON) -> JSONNode? {
        
        if json.type == .array { return node(withArray: json) }
        if json.type == .dictionary { return node(withDictionary: json) }
        
        return node(withObject: json)
    }
    
    private class func node(withObject obj: JSON) -> JSONNode? {
        
        let node = JSONLeafNode()
        let value: String?
        
        switch obj.type {
        case .string: value = obj.stringValue
        case .number: value = String(obj.intValue)
        case .null: value = nil
        default: print(obj); return nil
        }
        
        node.value = value
        
        return node
    }
    
    private class func node(withArray array: JSON) -> JSONNode {
        
        let node = JSONContainerNode()
        node.children = array.compactMap { _, json in JSONNode.nodeWithJSON(json) }
        
        return node
    }
    
    private class func node(withDictionary dict: JSON) -> JSONNode {
        
        let node = JSONContainerNode()
        node.children = dict.compactMap { (key: String, json: JSON) -> JSONNode? in
            
            if let node = JSONNode.nodeWithJSON(json) {
                
                node.key = key
                
                return node
            }
            
            return nil
        }
        
        return node
    }
    
    @objc var key: String?
    @objc var value: String?
    
    @objc var children: [JSONNode] = []
    @objc var isLeaf: Bool { return false }
    
    // MARK: - NSCoding, NSCopying
    required convenience init?(coder aDecoder: NSCoder) {
        
        self.init()
    }
    
    func encode(with aCoder: NSCoder) {
        
        fatalError("Subclass MUST implement this method")
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        fatalError("Subclass MUST implement this method")
    }
}

final class JSONContainerNode: JSONNode {
    
    override init() {
        
        super.init()
    }
    
    override var value: String? {
        
        get { return "\(children.count) items" }
        set {}
    }
    
    override func copy(with zone: NSZone?) -> Any {
        
        let node = JSONContainerNode()
        node.children = children
        
        return node
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        self.init()
        
        self.children = aDecoder.decodeObject(forKey: "children") as? [JSONNode] ?? []
    }
    
    override func encode(with aCoder: NSCoder) {
        
        aCoder.encode(children, forKey: "children")
    }
}

final class JSONLeafNode: JSONNode {
    
    override init() {
        
        super.init()
    }
    
    override var isLeaf: Bool { return true }
    
    override func copy(with zone: NSZone?) -> Any {
        
        let node = JSONLeafNode()
        node.key = key
        node.value = value
        
        return node
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        self.init()
        
        self.value = aDecoder.decodeObject(forKey: "value") as? String
        self.key = aDecoder.decodeObject(forKey: "key") as? String
    }
    
    override func encode(with aCoder: NSCoder) {
        
        aCoder.encode(value, forKey: "value")
        aCoder.encode(key, forKey: "key")
    }
}
