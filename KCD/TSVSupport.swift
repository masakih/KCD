//
//  File.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate struct LFSeparateLine {
    
    static let empty = LFSeparateLine(line: "", empty: true)
    
    let line: String
    
    private let isEmpty: Bool
    
    init(line: String, empty: Bool = false) {
        
        self.line = line
        isEmpty = empty
    }
    
    func append(_ column: String) -> LFSeparateLine {
        
        if isEmpty { return LFSeparateLine(line: column) }
        
        let newLine = line + "\t" + column
        
        return LFSeparateLine(line: newLine)
    }
    
    func append(_ dateCol: Date) -> LFSeparateLine {
        
        return append("\(dateCol)")
    }
    
    func append(_ intCol: Int) -> LFSeparateLine {
        
        return append("\(intCol)")
    }
    
    func append(_ boolCol: Bool) -> LFSeparateLine {
        
        return append("\(boolCol)")
    }
}

// swiftlint:disable type_body_length
final class TSVSupport {
    
    private let store = LocalDataStore.oneTimeEditor()
    
    private var dateFomatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss' 'Z"
        return formatter
    }()
    
    func load() {
        
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["kcdlocaldata"]
        panel.begin {
            
            guard $0 == NSModalResponseOK
                else { return }
            
            panel.urls.forEach { url in
                
                guard let fileW = try? FileWrapper(url: url)
                    else { return }
                
                fileW.fileWrappers?.forEach {
                    
                    guard let data = $0.value.regularFileContents
                        else { return }
                    
                    switch $0.key {
                    case "kaihatu.tsv": self.registerKaihatuHistory(data)
                    case "kenzo.tsv": self.registerKenzoHistory(data)
                    case "kenzoMark.tsv": self.registerKenzoMark(data)
                    case "dropShip.tsv": self.registerDropShipHistory(data)
                    default: break
                    }
                }
                
            }
        }
    }
    
    func save() {
        
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["kcdlocaldata"]
        panel.begin {
            
            guard $0 == NSModalResponseOK,
                let url = panel.url
                else { return }
            guard let kaihatuHistory = self.dataOfKaihatuHistory(),
                let kenzoHistory = self.dataOfKenzoHistory(),
                let kenzoMark = self.dataOfKenzoMark(),
                let dropShipHistory = self.dataOfDropShipHistory()
                else { return }
            
            let fileW = FileWrapper(directoryWithFileWrappers: [:])
            fileW.addRegularFile(withContents: kaihatuHistory, preferredFilename: "kaihatu.tsv")
            fileW.addRegularFile(withContents: kenzoHistory, preferredFilename: "kenzo.tsv")
            fileW.addRegularFile(withContents: kenzoMark, preferredFilename: "kenzoMark.tsv")
            fileW.addRegularFile(withContents: dropShipHistory, preferredFilename: "dropShip.tsv")
            do {
                
                try fileW.write(to: url, originalContentsURL: nil)
                
            } catch {
                
                print("Error to write")
            }
        }
    }
    
    private func localData<T>(_ entity: Entity<T>, sortBy: String = "date") -> [T] {
        
        let sortDesc = NSSortDescriptor(key: sortBy, ascending: true)
        
        guard let array = try? store.objects(with: entity, sortDescriptors: [sortDesc])
            else {
                print("Can not get \(entity.name)")
                return []
        }
        
        return array
    }
    
    private func dataOfKaihatuHistory() -> Data? {
        
        return localData(KaihatuHistory.entity)
            .map {
                LFSeparateLine.empty
                    .append($0.date)
                    .append($0.fuel)
                    .append($0.bull)
                    .append($0.steel)
                    .append($0.bauxite)
                    .append($0.kaihatusizai)
                    .append($0.name)
                    .append($0.flagShipName)
                    .append($0.flagShipLv)
                    .append($0.commanderLv)
                    .line
            }
            .joined(separator: "\n")
            .data(using: .utf8)
    }
    
    private func dataOfKenzoHistory() -> Data? {
        
        return localData(KenzoHistory.entity)
            .map {
            LFSeparateLine.empty
                .append($0.date)
                .append($0.fuel)
                .append($0.bull)
                .append($0.steel)
                .append($0.bauxite)
                .append($0.kaihatusizai)
                .append($0.name)
                .append($0.sTypeId)
                .append($0.flagShipName)
                .append($0.flagShipLv)
                .append($0.commanderLv)
                .line
            }
            .joined(separator: "\n")
            .data(using: .utf8)
    }
    
    private func dataOfKenzoMark() -> Data? {
        
        return localData(KenzoMark.entity, sortBy: "kDockId")
            .map {
            LFSeparateLine.empty
                .append($0.date)
                .append($0.fuel)
                .append($0.bull)
                .append($0.steel)
                .append($0.bauxite)
                .append($0.kaihatusizai)
                .append($0.created_ship_id)
                .append($0.kDockId)
                .append($0.flagShipName)
                .append($0.flagShipLv)
                .append($0.commanderLv)
                .line
            }
            .joined(separator: "\n")
            .data(using: .utf8)
    }
    
    private func dataOfDropShipHistory() -> Data? {
        
        return localData(DropShipHistory.entity)
            .map {
                LFSeparateLine.empty
                    .append($0.date)
                    .append($0.shipName)
                    .append($0.mapArea)
                    .append($0.mapInfo)
                    .append($0.mapCell)
                    .append($0.mapAreaName)
                    .append($0.mapInfoName)
                    .append($0.mark)
                    .append($0.winRank)
                    .line
            }
            .joined(separator: "\n")
            .data(using: .utf8)
    }
    
    private func registerKaihatuHistory(_ data: Data) {
        
        let array = String(data: data, encoding: .utf8)?.components(separatedBy: "\n")
        let store = LocalDataStore.oneTimeEditor()
        array?.forEach {
            
            let attr = $0.components(separatedBy: "\t")
            
            guard attr.count == 10,
                let date = dateFomatter.date(from: attr[0]),
                let fuel = Int(attr[1]),
                let bull = Int(attr[2]),
                let steel = Int(attr[3]),
                let bauxite = Int(attr[4]),
                let kaihatu = Int(attr[5]),
                let flagLv = Int(attr[8]),
                let commandLv = Int(attr[9])
                else { return }
            
            let p = NSPredicate(format: "date = %@", argumentArray: [date])
            
            guard let oo = try? store.objects(with: KaihatuHistory.entity, predicate: p),
                oo.count != 0
                else { return }
            
            guard let obj = store.insertNewObject(for: KaihatuHistory.entity)
                else { return }
            
            obj.date = date
            obj.fuel = fuel
            obj.bull = bull
            obj.steel = steel
            obj.bauxite = bauxite
            obj.kaihatusizai = kaihatu
            obj.name = attr[6]
            obj.flagShipName = attr[7]
            obj.flagShipLv = flagLv
            obj.commanderLv = commandLv
        }
    }
    
    private func registerKenzoHistory(_ data: Data) {
        
        let array = String(data: data, encoding: .utf8)?.components(separatedBy: "\n")
        let store = LocalDataStore.oneTimeEditor()
        
        array?.forEach {
            
            let attr = $0.components(separatedBy: "\t")
            
            guard attr.count == 11,
                let date = dateFomatter.date(from: attr[0]),
                let fuel = Int(attr[1]),
                let bull = Int(attr[2]),
                let steel = Int(attr[3]),
                let bauxite = Int(attr[4]),
                let kaihatu = Int(attr[5]),
                let sType = Int(attr[7]),
                let flagLv = Int(attr[9]),
                let commandLv = Int(attr[10])
                else { return }
            
            let p = NSPredicate(format: "date = %@", argumentArray: [date])
            
            guard let oo = try? store.objects(with: KenzoHistory.entity, predicate: p),
                oo.count != 0
                else { return }
            
            guard let obj = store.insertNewObject(for: KenzoHistory.entity)
                else { return }
            
            obj.date = date
            obj.fuel = fuel
            obj.bull = bull
            obj.steel = steel
            obj.bauxite = bauxite
            obj.kaihatusizai = kaihatu
            obj.name = attr[6]
            obj.sTypeId = sType
            obj.flagShipName = attr[8]
            obj.flagShipLv = flagLv
            obj.commanderLv = commandLv
        }
    }
    
    private func registerKenzoMark( _ data: Data) {
        
        let array = String(data: data, encoding: .utf8)?.components(separatedBy: "\n")
        let store = LocalDataStore.oneTimeEditor()
        
        array?.forEach {
            
            let attr = $0.components(separatedBy: "\t")
            
            guard attr.count == 11,
                let date = dateFomatter.date(from: attr[0]),
                let fuel = Int(attr[1]),
                let bull = Int(attr[2]),
                let steel = Int(attr[3]),
                let bauxite = Int(attr[4]),
                let kaihatu = Int(attr[5]),
                let shiId = Int(attr[6]),
                let kDock = Int(attr[7]),
                let flagLv = Int(attr[9]),
                let commandLv = Int(attr[10])
                else { return }
            
            let p = NSPredicate(format: "date = %@", argumentArray: [date])
            
            guard let oo = try? store.objects(with: KenzoMark.entity, predicate: p),
                oo.count != 0
                else { return }
            
            guard let obj = store.insertNewObject(for: KenzoMark.entity)
                else { return }
            
            obj.date = date
            obj.fuel = fuel
            obj.bull = bull
            obj.steel = steel
            obj.bauxite = bauxite
            obj.kaihatusizai = kaihatu
            obj.created_ship_id = shiId
            obj.kDockId = kDock
            obj.flagShipName = attr[8]
            obj.flagShipLv = flagLv
            obj.commanderLv = commandLv
        }
    }
    
    private func registerDropShipHistory( _ data: Data) {
        
        let array = String(data: data, encoding: .utf8)?.components(separatedBy: "\n")
        let store = LocalDataStore.oneTimeEditor()
        
        array?.forEach {
            
            let attr = $0.components(separatedBy: "\t")
            
            guard attr.count == 9,
                let date = dateFomatter.date(from: attr[0]),
                let mapInfo = Int(attr[3]),
                let mapCell = Int(attr[4]),
                let mark = Int(attr[7])
                else { return }
            
            let p = NSPredicate(format: "date = %@", argumentArray: [date])
            
            guard let oo = try? store.objects(with: DropShipHistory.entity, predicate: p),
                oo.count != 0
                else { return }
            
            guard let obj = store.insertNewObject(for: DropShipHistory.entity)
                else { return }
            
            obj.date = date
            obj.shipName = attr[1]
            obj.mapArea = attr[2]
            obj.mapInfo = mapInfo
            obj.mapCell = mapCell
            obj.mapAreaName = attr[5]
            obj.mapInfoName = attr[6]
            obj.mark = mark != 0
            obj.winRank = attr[8]
        }
    }
}
