//
//  JSONMapper.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

struct MappingConfiguration<T: NSManagedObject> {
    let entity: Entity<T>
    let dataKey: String
    let primaryKey: String
    let compositPrimaryKeys: [String]?
    let editorStore: CoreDataAccessor
    let ignoreKeys: [String]
    
    init(entity: Entity<T>,
         dataKey: String = "api_data",
         primaryKey: String = "id",
         compositPrimaryKeys: [String]? = nil,
         editorStore: CoreDataAccessor,
         ignoreKeys: [String] = []) {
        self.entity = entity
        self.dataKey = dataKey
        self.primaryKey = primaryKey
        self.compositPrimaryKeys = compositPrimaryKeys
        self.editorStore = editorStore
        self.ignoreKeys = ignoreKeys
    }
}

protocol JSONMapper {
    associatedtype ObjectType: NSManagedObject
    
    init(_ apiResponse: APIResponse)
    
    var apiResponse: APIResponse { get }
    var configuration: MappingConfiguration<ObjectType> { get }
    
    func registerElement(_ element: [String: Any], to object: ObjectType)
    func commit()
    func beginRegister(_ object: ObjectType)
    func handleExtraValue(_ value: Any, forKey key: String, to object: ObjectType) -> Bool
    func finishOperating()
}

extension String {
    func keyByDeletingPrefix() -> String {
        if self.characters.count < 5 { return self }
        let s = self.index(self.startIndex, offsetBy: 4)
        return self[s..<self.endIndex]
    }
}

extension JSONMapper {
    private func isEqual(_ a: AnyObject?, _ b: AnyObject?) -> Bool {
        if a == nil, b == nil { return true }
        if let aa = a, let bb = b { return aa.isEqual(bb) }
        return false
    }
    func setValueIfNeeded(_ value: AnyObject?, to object: ObjectType, forKey key: String) {
        var validValue = value
        do { try object.validateValue(&validValue, forKey: key) }
        catch { return }
        
        let old = object.value(forKey: key)
        if !isEqual(old as AnyObject?, validValue) {
            object.willChangeValue(forKey: key)
            object.setValue(validValue, forKey: key)
            object.didChangeValue(forKey: key)
        }
    }
    
    func registerElement(_ element: [String: Any], to object: ObjectType) {
        beginRegister(object)
        element.forEach { (key: String, value: Any) in
            if configuration.ignoreKeys.contains(key) { return }
            if handleExtraValue(value, forKey: key, to: object) { return }
            switch value {
            case let a as [AnyObject]:
                a.enumerated().forEach {
                    let newKey = "\(key)_\($0.offset)"
                    setValueIfNeeded($0.element, to: object, forKey: newKey)
                }
            case let d as [String: AnyObject]:
                d.forEach { (subKey: String, subValue) in
                    let newKey = "\(key)_D_\(subKey.keyByDeletingPrefix())"
                    setValueIfNeeded(subValue, to: object, forKey: newKey)
                }
            default:
                setValueIfNeeded(value as AnyObject?, to: object, forKey: key)
            }
        }
    }
    private var sortDescriptors: [NSSortDescriptor] {
        let keys = configuration.compositPrimaryKeys ?? [configuration.primaryKey]
        return keys.map { NSSortDescriptor(key: $0, ascending: true) }
    }
    private func objectSearch(_ objects: [ObjectType], _ element: [String: Any]) -> ObjectType? {
        let keys = configuration.compositPrimaryKeys ?? [configuration.primaryKey]
        let keyPiar = keys.map { (key: $0, apiKey: "api_\($0)") }
        return objects.binarySearch {
            for piar in keyPiar {
                guard let v1 = $0.value(forKey: piar.key)
                    else { return .orderedAscending }
                guard let v2 = element[piar.apiKey]
                    else { return .orderedDescending }
                return (v1 as AnyObject).compare(v2)
            }
            return .orderedDescending
        }
    }
    func commit() {
        guard var d = (apiResponse.json as AnyObject).value(forKeyPath: configuration.dataKey)
            else { return print("JSON is wrong.") }
        if let dd = d as? NSDictionary { d = [dd] }
        guard let data = d as? [[String: Any]]
            else { return print("JSON is wrong.") }
        
        let store = configuration.editorStore
        guard let objects = try? store.objects(with: configuration.entity, sortDescriptors: sortDescriptors)
            else { return print("Can not get entity named \(configuration.entity.name)") }
        data.forEach {
            if let object = objectSearch(objects, $0) {
                registerElement($0, to: object)
            } else if let new = store.insertNewObject(for: configuration.entity) {
                registerElement($0, to: new)
            } else {
                fatalError("Can not get entity named \(configuration.entity.name)")
            }
        }
        finishOperating()
        store.saveActionCore()
    }
    
    func execute() {}
    func beginRegister(_ object: ObjectType) {}
    func handleExtraValue(_ value: Any, forKey key: String, to object: ObjectType) -> Bool {
        return false
    }
    func finishOperating() {}
}



