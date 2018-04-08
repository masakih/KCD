//
//  ScreenshotInformation.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/28.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class ScreenshotModel: NSObject {
    
    @objc dynamic var screenshots: [ScreenshotInformation] = []
    @objc dynamic var sortDescriptors: [NSSortDescriptor]?
    @objc dynamic var selectedIndexes: IndexSet?
    @objc dynamic var filterPredicate: NSPredicate?
}

final class ScreenshotInformation: NSObject, NSCoding {
    
    @objc let url: URL
    
    @objc lazy var image: NSImage? = {
        
        guard let image = NSImage(contentsOf: url) else {
            
            Logger.shared.log("Can not load image")
            
            return nil
        }
        
        return image
    }()
    
    @objc var creationDate: Date? {
        
        let attr = try? url.resourceValues(forKeys: [.creationDateKey])
        
        return attr?.creationDate
    }
    
    @objc var tags: [String]? {
        
        get {
            
            let attr = try? url.resourceValues(forKeys: [.tagNamesKey])
            
            return attr?.tagNames
        }
        
        set {
            
            let url = self.url as NSURL
            do {
                
                if let array = newValue {
                    
                    try url.setResourceValue(array as NSArray, forKey: .tagNamesKey)
                    
                } else {
                    
                    try url.setResourceValue([] as NSArray, forKey: .tagNamesKey)
                }
                
            } catch {
                
                print("Can not set tagNames")
            }
        }
    }
    
    private(set) var version: Int
    
    init(url: URL, version: Int = 0) {
        
        self.url = url
        self.version = version
        
        super.init()
    }
    
    func incrementVersion() { version = version + 1 }
    
    // MARK: - NSCoding
    struct CodingKey {
        
        static let url = "Url"
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let u = aDecoder.decodeObject(forKey: CodingKey.url) as? URL else {
            
            return nil
        }
        
        self.init(url: u)
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(url, forKey: CodingKey.url)
    }
}

private let dateFormatter: DateFormatter = {
    
    let f = DateFormatter()
    f.dateStyle = .short
    f.timeStyle = .short
    f.doesRelativeDateFormatting = true
    
    return f
}()

extension ScreenshotInformation {
    
    @objc var name: String? {
        
        let attr = try? url.resourceValues(forKeys: [.localizedNameKey])
        
        return attr?.localizedName
    }
    
    @objc var creationDateString: String? {
        
        return creationDate.map(dateFormatter.string(from:))
    }
}
