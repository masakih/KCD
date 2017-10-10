//
//  ResetSortie.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/02/24.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Foundation

final class ResetSortie {
    
    func reset() {
        
        let store = TemporaryDataStore.oneTimeEditor()
        
        store.battles().forEach(store.delete)
    }
}
