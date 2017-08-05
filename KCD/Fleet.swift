//
//  Fleet.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

fileprivate var pDeckContext = 0

final class Fleet: NSObject {
    
    let fleetNumber: Int
    
    private let deckObserveKeys = [
        "selection.ship_0", "selection.ship_1", "selection.ship_2",
        "selection.ship_3", "selection.ship_4", "selection.ship_5"
    ]
    
    init?(number: Int) {
        
        guard case 1...4 = number
            else {
                print("Fleet number out of range")
                return nil
        }
        
        fleetNumber = number
        deckController = NSObjectController()
        
        super.init()
        
        deckController.entityName = Deck.entityName
        deckController.managedObjectContext = ServerDataStore.default.context
        deckController.fetchPredicate = NSPredicate(format: "id = %ld", number)
        let req = NSFetchRequest<NSFetchRequestResult>()
        req.entity = NSEntityDescription.entity(forEntityName: Deck.entityName,
                                                in: deckController.managedObjectContext!)
        req.predicate = deckController.fetchPredicate
        
        do {
            
            try deckController.fetch(with: req, merge: false)
            
        } catch {
            
            print("Fetch error")
            return nil
            
        }
        
        deck = deckController.content as? Deck
        deckObserveKeys.forEach { deckController.addObserver(self, forKeyPath: $0, context: &pDeckContext) }
    }
    
    deinit {
        
        deckObserveKeys.forEach { deckController.removeObserver(self, forKeyPath: $0) }
        
    }
    
    dynamic private(set) var ships: [Ship] = []
    private let deckController: NSObjectController
    private weak var deck: Deck?
    
    dynamic var name: String? { return deck?.name }
    class func keyPathsForValuesAffectingName() -> Set<String> {
        
        return ["deck.name"]
    }
    dynamic var id: NSNumber? { return deck?.id as NSNumber? }
    class func keyPathesForValuesAffectiongId() -> Set<String> {
        
        return ["deck.id"]
    }
    
    subscript(_ index: Int) -> Ship? { return deck?[index] }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == &pDeckContext {
            
            ships = (0..<6).flatMap { return self[$0] }
            
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
}
