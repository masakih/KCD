//
//  BookmarkItem.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/28.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class Bookmark: NSManagedObject {
    
    @NSManaged var identifier: String
    @NSManaged var name: String
    @NSManaged var urlString: String
    @NSManaged var canScroll: Bool
    @NSManaged var canResize: Bool
    @NSManaged var windowContentSizeString: String
    @NSManaged var contentVisibleRectString: String
    @NSManaged var order: Int
    @NSManaged var scrollDelayValue: Float
}

extension Bookmark {
    
    var windowContentSize: NSSize {
        
        get { return NSSizeFromString(windowContentSizeString) }
        set { windowContentSizeString = NSStringFromSize(newValue) }
    }
    
    var contentVisibleRect: NSRect {
        
        get { return NSRectFromString(contentVisibleRectString) }
        set { contentVisibleRectString = NSStringFromRect(newValue) }
    }
    
    var scrollDelay: TimeInterval {
        
        get { return TimeInterval(scrollDelayValue) }
        set { scrollDelayValue = Float(newValue) }
    }
}

extension Bookmark: NSPasteboardWriting {
    
    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        
        return [NSPasteboard.PasteboardType("com.masakih.KCD.BookmarkItem")]
    }
    
    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        
        let uri = objectID.uriRepresentation()
        
        return NSKeyedArchiver.archivedData(withRootObject: uri)
    }
}
