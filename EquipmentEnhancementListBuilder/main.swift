//
//  main.swift
//  EquipmentEnhancementListBuilder
//
//  Created by Hori,Masaki on 2017/01/24.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

struct TabSeparatedLine {
    let value: String
    var count: Int { return columns.count }
    var columns: [String] { return value.components(separatedBy: "\t") }
    subscript(_ index: Int) -> String { return columns[index] }
}

struct ThreeItemsQueue<T> {
    var items: [T] = []
    var count: Int { return items.count }
    mutating func push(item: T) {
        if count < 3 {
            items += [item]
            return
        }
        items = items[1...2] + [item]
    }
    subscript(_ index: Int) -> T { return items[index] }
}

fileprivate extension RequiredEquipment {
    convenience init?(lines: TabSeparatedLine) {
        guard lines.count == 6 else { return nil }
        guard let nu = Int(lines[3]),
            let s = Int(lines[4]),
            let e = Int(lines[5])
            else { return nil }
        self.init(identifier: lines[0],
                  levelRange: lines[1],
                  name: lines[2],
                  number: nu,
                  screw: s,
                  ensureScrew: e)
    }
}
fileprivate extension RequiredEquipmentSet {
    convenience init?(items: [RequiredEquipment]) {
        guard items.count == 3 else { return nil }
        guard items[0].identifier == items[1].identifier,
            items[1].identifier == items[2].identifier
            else { return nil }
        self.init(identifier: items[0].identifier,
                  requiredEquipments: items)
        print("Create item of \(items[0].identifier)")
    }
}
fileprivate extension EnhancementListItem {
    convenience init?(line: TabSeparatedLine, equSets: [RequiredEquipmentSet]) {
        guard line.count == 6 else {print("count not 6"); return nil }
        guard let i = equSets.index(where: { $0.identifier == line[0] })
            else {
                print("Do not find \(line[0]) in EnhancementListItem.txt")
                return nil
        }
        guard let w = Int(line[1]),
            let raw = Int(line[2]),
            let type = EquipmentType(rawValue: raw)
            else { return nil }
        
        self.init(identifier: line[0],
                  weekday: w,
                  equipmentType: type,
                  targetEquipment: line[3],
                  remodelEquipment: line[4],
                  requiredEquipments: equSets[i],
                  secondsShipNames: line[5].components(separatedBy: ","))
        print("Add item \(line[3]) for weekday \(w)")
    }
}

func generate(threeLines: ThreeItemsQueue<TabSeparatedLine>) -> [RequiredEquipment] {
    return threeLines.items.flatMap { RequiredEquipment(lines: $0) }
}

//
func loadFile(path: String) -> String? {
    do { return try String(contentsOfFile: path) }
    catch {
        print("Can not create String from \(path)")
        return nil
    }
}

// MARK: ここから
let arguments = CommandLine.arguments
guard arguments.count > 1
    else {
        print("argument too few")
        fatalError()
}

let targetDirectory = arguments[1] as NSString
let requiredEquipmentSetPath = targetDirectory.appendingPathComponent("RequiredEquipmentSet.txt")
guard let requiredEquipmentSetText = loadFile(path: requiredEquipmentSetPath)
    else { fatalError() }

//
var threeLines = ThreeItemsQueue<TabSeparatedLine>()
let requiredEquipmentSet = requiredEquipmentSetText
    .components(separatedBy: "\n")
    .map { TabSeparatedLine(value: $0) }
    .flatMap { (line: TabSeparatedLine) -> ThreeItemsQueue<TabSeparatedLine> in
        threeLines.push(item: line)
        return threeLines
    }
    .map { generate(threeLines: $0) }
    .flatMap { RequiredEquipmentSet(items: $0) }

//
let enhancementListItemPath = targetDirectory.appendingPathComponent("EnhancementListItem.txt")
guard let enhancementListText = loadFile(path: enhancementListItemPath)
    else { fatalError() }
let listItems = enhancementListText
    .components(separatedBy: "\n")
    .map { TabSeparatedLine(value: $0) }
    .flatMap { EnhancementListItem(line: $0, equSets: requiredEquipmentSet) }

//
NSKeyedArchiver.setClassName("KCD.EnhancementListItem", for: EnhancementListItem.self)
NSKeyedArchiver.setClassName("KCD.RequiredEquipmentSet", for: RequiredEquipmentSet.self)
NSKeyedArchiver.setClassName("KCD.RequiredEquipment", for: RequiredEquipment.self)

print("Register \(listItems.count) items.")

let outfile = targetDirectory.appendingPathComponent("EnhancementListItem2.plist")
NSKeyedArchiver.archiveRootObject(listItems, toFile: outfile)
