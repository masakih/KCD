//
//  Logger.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/10/28.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

final class Logger {
    
    let destination: URL
    
    lazy private var dateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        return formatter
    }()
    
    lazy private var fileHandle: FileHandle? = {
        
        FileManager.default.createFile(atPath: destination.path, contents: nil, attributes: nil)
        
        do {
            
            return try FileHandle(forWritingTo: destination)
            
        } catch {
            
            print("Could not open path to log file. \(error).")
        }
        
        return nil
    }()
    
    init(destination: URL) {
        
        self.destination = destination
    }
    
    deinit {
        
        fileHandle?.closeFile()
    }
    
    func log(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
        
        let logMessage = stringRepresentation(message, function: function, file: file, line: line)
        
        printToConsole(logMessage)
        printToDestination(logMessage)
    }
    func log<T>(_ message: String, value: T, function: String = #function, file: String = #file, line: Int = #line) -> T {
        
        let logMessage = stringRepresentation(message, function: function, file: file, line: line)
        
        printToConsole(logMessage)
        printToDestination(logMessage)
        
        return value
    }
}

private extension Logger {
    
    func stringRepresentation(_ message: String, function: String, file: String, line: Int) -> String {
        
        let dateString = dateFormatter.string(from: Date())
        
        let file = URL(fileURLWithPath: file).lastPathComponent
        
        return "\(dateString) [\(file):\(line)] \(function): \(message)\n"
    }
    
    func printToConsole(_ logMessage: String) {
        
        print(logMessage)
    }
    
    func printToDestination(_ logMessage: String) {
        
        if let data = logMessage.data(using: .utf8) {
            
            fileHandle?.write(data)
            
        } else {
            
            print("Could not encode logged string into data.")
        }
    }
}
