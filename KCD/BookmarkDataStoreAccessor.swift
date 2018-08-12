//
//  BookmarkDataStoreAccessor.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/10/25.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

extension BookmarkDataStore {
    
    func createBookmark() -> Bookmark? {
        
        return insertNewObject(for: Bookmark.self)
    }
}
