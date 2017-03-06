//
//  JSONNode.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class JSONNode: NSObject, NSCoding, NSCopying {
    class func nodeWithJSON(_ json: AnyObject?) -> JSONNode? {
        if let j = json as? NSArray { return node(withArray: j) }
        if let j = json as? NSDictionary { return node(withDictionary: j) }
        return node(withObject: json)
    }
    private class func node(withObject obj: AnyObject?) -> JSONNode? {
        guard let obj = obj else { return nil }
        let node = JSONLeafNode()
        let value: String?
        switch obj {
        case let v as String: value = v
        case let v as Int: value = String(v)
        case _ as NSNull: value = nil
        default: print(obj); return nil
        }
        node.value = value
        return node
    }
    private class func node(withArray array: NSArray) -> JSONNode {
        let node = JSONContainerNode()
        node.children = array.map {
            if let node = JSONNode.nodeWithJSON($0 as AnyObject?) { return node }
            
            
            // TODO: check enter below
            print("Enter JSONNode ARRAY optional statment")
            let node = JSONLeafNode()
            let value: String?
            switch $0 {
            case let v as String: value = v
            case let v as Int: value = String(v)
            case _ as NSNull: value = nil
            default: print($0); fatalError()
            }
            node.value = value
            return node
        }
        return node
    }
    private class func node(withDictionary dict: NSDictionary) -> JSONNode {
        guard let dict = dict as? [String: AnyObject] else { fatalError("JSON is broken.") }
        let node = JSONContainerNode()
        node.children = dict.map { (d: (key: String, value: AnyObject)) -> JSONNode in
            if let node = JSONNode.nodeWithJSON(d.value) {
                node.key = d.key
                return node
            }
            
            // TODO: check enter below
            print("Enter JSONNode DICTIONAY optional statment")
            let node = JSONLeafNode()
            node.key = d.key
            let value: String?
            switch d.value {
            case let v as String: value = v
            case let v as Int: value = String(v)
            case _ as NSNull: value = nil
            default: print(d.value); fatalError()
            }
            node.value = value
            return node
        }
        return node
    }
    
    var key: String?
    var value: String?
    
    var children: [JSONNode] = []
    var isLeaf: Bool { return false }
    
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

class JSONContainerNode: JSONNode {
    override init() {
        super.init()
    }
    
    override var value: String? {
        get {
            return "\(children.count) items"
        }
        set {}
    }
    
    override func copy(with zone: NSZone?) -> Any {
        let node = JSONContainerNode()
        node.children = children
        return node
    }
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.children = (aDecoder.decodeObject(forKey: "children") as! [JSONNode]?)!
    }
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(children, forKey: "children")
    }
}

class JSONLeafNode: JSONNode {
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
        self.value = aDecoder.decodeObject(forKey: "value") as! String?
        self.key = aDecoder.decodeObject(forKey: "key") as! String?
    }
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(value, forKey: "value")
        aCoder.encode(key, forKey: "key")
    }
}
