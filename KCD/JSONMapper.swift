//
//  JSONMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import SwiftyJSON

struct MappingConfiguration<T: NSManagedObject> {
    
    let entity: Entity<T>
    let dataKeys: [String]
    let primaryKeys: [String]
    let editorStore: CoreDataAccessor
    let ignoreKeys: [String]
    
    init(entity: Entity<T>,
         dataKeys: [String] = ["api_data"],
         primaryKeys: [String] = ["id"],
         editorStore: CoreDataAccessor,
         ignoreKeys: [String] = []) {
        
        self.entity = entity
        self.dataKeys = dataKeys
        self.primaryKeys = primaryKeys
        self.editorStore = editorStore
        self.ignoreKeys = ignoreKeys
    }
}

protocol JSONMapper {
    
    associatedtype ObjectType: NSManagedObject
    
    init(_ apiResponse: APIResponse)
    
    var apiResponse: APIResponse { get }
    var configuration: MappingConfiguration<ObjectType> { get }
    
    func registerElement(_ element: JSON, to object: ObjectType)
    func commit()
    func beginRegister(_ object: ObjectType)
    func handleExtraValue(_ value: JSON, forKey key: String, to object: ObjectType) -> Bool
    func finishOperating()
}

extension String {
    // delete api_ prefix.
    func keyByDeletingPrefix() -> String {
        
        if self.count < 5 { return self }
        
        return String(self[index(startIndex, offsetBy: 4)...])
    }
}

extension JSONMapper {
    
    var data: JSON { return apiResponse.json[configuration.dataKeys] }
    
    private func isEqual(_ lhs: AnyObject?, _ rhs: AnyObject?) -> Bool {
        
        if lhs == nil, rhs == nil { return true }
        if let lhs = lhs, let rhs = rhs { return lhs.isEqual(rhs) }
        
        return false
    }
    
    func setValueIfNeeded(_ value: JSON, to object: ObjectType, forKey key: String) {
        
        var validValue = value.object as AnyObject?
        do {
            
            try object.validateValue(&validValue, forKey: key)
            
        } catch {
            
            return
        }
        
        let old = object.value(forKey: key)
        if !isEqual(old as AnyObject?, validValue) {
            
            object.notifyChangeValue(forKey: key) {
                
                object.setValue(validValue, forKey: key)
            }
        }
    }
    
    func registerElement(_ element: JSON, to object: ObjectType) {
        
        beginRegister(object)
        element.forEach { (key, value) in
            
            if configuration.ignoreKeys.contains(key) { return }
            if handleExtraValue(value, forKey: key, to: object) { return }
            
            switch value.type {
            case .array:
                value.array?.enumerated().forEach {
                    
                    let newKey = "\(key)_\($0.offset)"
                    setValueIfNeeded($0.element, to: object, forKey: newKey)
                }
                
            case .dictionary:
                value.forEach { (subKey: String, subValue) in
                    
                    let newKey = "\(key)_D_\(subKey.keyByDeletingPrefix())"
                    setValueIfNeeded(subValue, to: object, forKey: newKey)
                }
            default:
                
                setValueIfNeeded(value, to: object, forKey: key)
            }
        }
    }
    
    private var sortDescriptors: [NSSortDescriptor] {
        
        return configuration.primaryKeys.map { NSSortDescriptor(key: $0, ascending: true) }
    }
    
    private func objectSearch(_ objects: [ObjectType], _ element: JSON) -> ObjectType? {
        
        let keyPiar = configuration.primaryKeys.map { (key: $0, apiKey: "api_\($0)") }
        
        return objects.binarySearch {
            
            // TODO: replace to forEach
            for piar in keyPiar {
                
                guard let v1 = $0.value(forKey: piar.key) else { return .orderedAscending }
                
                if element[piar.apiKey].type == .null { return .orderedDescending }
                
                let v2 = element[piar.apiKey].object
                
                return (v1 as AnyObject).compare(v2)
            }
            
            return .orderedDescending
        }
    }
    
    func commit() {
        
        let store = configuration.editorStore
        
        guard let objects = try? store.objects(of: configuration.entity, sortDescriptors: sortDescriptors) else {
            
            return Logger.shared.log("Can not get entity named \(configuration.entity.name)")
        }
        
        let list = (data.type == .array ? data.arrayValue : [data])
        list.forEach {
            
            if let object = objectSearch(objects, $0) {
                
                registerElement($0, to: object)
                
            } else if let new = store.insertNewObject(for: configuration.entity) {
                
                registerElement($0, to: new)
                
            } else {
                
                fatalError("Can not get entity named \(configuration.entity.name)")
            }
        }
        
        finishOperating()
        store.save(errorHandler: store.presentOnMainThread)
    }
    
    func beginRegister(_ object: ObjectType) {}
    
    func handleExtraValue(_ value: JSON, forKey key: String, to object: ObjectType) -> Bool {
        
        return false
    }
    
    func finishOperating() {}
}
