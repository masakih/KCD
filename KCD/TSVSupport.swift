//
//  File.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/05.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa
import Doutaku

private struct LFSeparateLine {
    
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
            
            guard $0 == .OK else {
                
                return
            }
            
            panel.urls.forEach { url in
                
                guard let fileW = try? FileWrapper(url: url) else {
                    
                    return
                }
                
                fileW.fileWrappers?.forEach {
                    
                    guard let data = $0.value.regularFileContents else {
                        
                        return
                    }
                    
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
            
            guard $0 == .OK else {
                
                return
            }
            guard let url = panel.url else {
                
                return
            }
            
            let data = self.store.sync { () -> (Data, Data, Data, Data)? in
                
                guard let kaihatuHistory = self.dataOfKaihatuHistory() else {
                    
                    return nil
                }
                guard let kenzoHistory = self.dataOfKenzoHistory() else {
                    
                    return nil
                }
                guard let kenzoMark = self.dataOfKenzoMark() else {
                    
                    return nil
                }
                guard let dropShipHistory = self.dataOfDropShipHistory() else {
                    
                    return nil
                }
                
                return (kaihatuHistory, kenzoHistory, kenzoMark, dropShipHistory)
            }
            guard let (kaihatuHistory, kenzoHistory, kenzoMark, dropShipHistory) = data else {
                
                return
            }
            
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
    
    private func localData<ResultType: Entity, Value>(_ type: ResultType.Type, sortBy: KeyPath<ResultType, Value>) -> [ResultType] {
        
        let sortDesc = SortDescriptors(keyPath: sortBy, ascending: true)
        
        guard let array = try? store.objects(of: type, sortDescriptors: sortDesc) else {
            
            print("Can not get \(type)")
            
            return []
        }
        
        return array
    }
    
    private func dataOfKaihatuHistory() -> Data? {
        
        return localData(KaihatuHistory.self, sortBy: \KaihatuHistory.date)
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
        
        return localData(KenzoHistory.self, sortBy: \KenzoHistory.date)
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
        
        return localData(KenzoMark.self, sortBy: \KenzoMark.kDockId)
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
        
        return localData(DropShipHistory.self, sortBy: \DropShipHistory.date)
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
        array?.forEach {
            
            let attr = $0.components(separatedBy: "\t")
            
            guard attr.count == 10 else {
                
                return
            }
            guard let date = dateFomatter.date(from: attr[0]) else {
                
                return
            }
            guard let fuel = Int(attr[1]) else {
                
                return
            }
            guard let bull = Int(attr[2]) else {
                
                return
            }
            guard let steel = Int(attr[3]) else {
                
                return
            }
            guard let bauxite = Int(attr[4]) else {
                
                return
            }
            guard let kaihatu = Int(attr[5]) else {
                
                return
            }
            guard let flagLv = Int(attr[8]) else {
                
                return
            }
            guard let commandLv = Int(attr[9]) else {
                
                return
            }
            
            let predicate = Predicate(\KaihatuHistory.date, equalTo: date)
            
            guard let oo = try? store.objects(of: KaihatuHistory.self, predicate: predicate) else {
                
                return
            }
            guard oo.count != 0 else {
                
                return
            }
            guard let obj = store.insertNewObject(for: KaihatuHistory.self) else {
                
                return
            }
            
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
        
        array?.forEach {
            
            let attr = $0.components(separatedBy: "\t")
            
            guard attr.count == 11 else {
                
                return
            }
            guard let date = dateFomatter.date(from: attr[0]) else {
                
                return
            }
            guard let fuel = Int(attr[1]) else {
                
                return
            }
            guard let bull = Int(attr[2]) else {
                
                return
            }
            guard let steel = Int(attr[3]) else {
                
                return
            }
            guard let bauxite = Int(attr[4]) else {
                
                return
            }
            guard let kaihatu = Int(attr[5]) else {
                
                return
            }
            guard let sType = Int(attr[7]) else {
                
                return
            }
            guard let flagLv = Int(attr[9]) else {
                
                return
            }
            guard let commandLv = Int(attr[10]) else {
                
                return
            }
            
            let predicate = Predicate(\KenzoHistory.date, equalTo: date)
            
            guard let oo = try? store.objects(of: KenzoHistory.self, predicate: predicate) else {
                
                return
            }
            guard oo.count != 0 else {
                
                return
            }
            guard let obj = store.insertNewObject(for: KenzoHistory.self) else {
                
                return
            }
            
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
        
        array?.forEach {
            
            let attr = $0.components(separatedBy: "\t")
            
            guard attr.count == 11 else {
                
                return
            }
            guard let date = dateFomatter.date(from: attr[0]) else {
                
                return
            }
            guard let fuel = Int(attr[1]) else {
                
                return
            }
            guard let bull = Int(attr[2]) else {
                
                return
            }
            guard let steel = Int(attr[3]) else {
                
                return
            }
            guard let bauxite = Int(attr[4]) else {
                
                return
            }
            guard let kaihatu = Int(attr[5]) else {
                
                return
            }
            guard let shiId = Int(attr[6]) else {
                
                return
            }
            guard let kDock = Int(attr[7]) else {
                
                return
            }
            guard let flagLv = Int(attr[9]) else {
                
                return
            }
            guard let commandLv = Int(attr[10]) else {
                
                return
            }
            
            let predicate = Predicate(\KenzoMark.date, equalTo: date)
            
            guard let oo = try? store.objects(of: KenzoMark.self, predicate: predicate) else {
                
                return
            }
            guard oo.count != 0 else {
                
                return
            }
            guard let obj = store.insertNewObject(for: KenzoMark.self) else {
                
                return
            }
            
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
        
        array?.forEach {
            
            let attr = $0.components(separatedBy: "\t")
            
            guard attr.count == 9 else {
                
                return
            }
            guard let date = dateFomatter.date(from: attr[0]) else {
                
                return
            }
            guard let mapInfo = Int(attr[3]) else {
                
                return
            }
            guard let mapCell = Int(attr[4]) else {
                
                return
            }
            guard let mark = Int(attr[7]) else {
                
                return
            }
            
            let predicate = Predicate(\DropShipHistory.date, equalTo: date)
            
            guard let oo = try? store.objects(of: DropShipHistory.self, predicate: predicate) else {
                
                return
            }
            guard oo.count != 0 else {
                
                return
            }
            guard let obj = store.insertNewObject(for: DropShipHistory.self) else {
                
                return
            }
            
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
