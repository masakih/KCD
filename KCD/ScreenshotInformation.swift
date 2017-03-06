//
//  ScreenshotInformation.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/28.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

class ScreenshotModel: NSObject {
    dynamic var screenshots: [ScreenshotInformation] = []
    dynamic var sortDescriptors: [NSSortDescriptor]?
    dynamic var selectedIndexes: IndexSet?
    dynamic var filterPredicate: NSPredicate?
}

class ScreenshotInformation: NSObject, NSCoding {
    let url: URL
    var creationDate: Date? {
        let attr = try? url.resourceValues(forKeys: [.creationDateKey])
        return attr?.creationDate
    }
    var tags: [String]? {
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
            }
            catch {
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
        static let version = "Version"
    }
    required convenience init?(coder aDecoder: NSCoder) {
        guard let u = aDecoder.decodeObject(forKey: CodingKey.url) as? URL
            else { return nil }
        self.init(url: u)
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(url, forKey: CodingKey.url)
    }
}

fileprivate let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .short
    f.timeStyle = .short
    f.doesRelativeDateFormatting = true
    return f
}()

extension ScreenshotInformation {
    var name: String? {
        let attr = try? url.resourceValues(forKeys: [.localizedNameKey])
        return attr?.localizedName
    }
    var creationDateString: String? {
        return creationDate
            .map { dateFormatter.string(from: $0) }
    }
}
