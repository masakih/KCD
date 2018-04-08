//
//  Fleet.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/01/22.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

final class DeckObserver {
    
    private let deck: Deck
    private let handler: (Deck) -> Void
    
    private var observation: [NSKeyValueObservation] = []
    
    init(deck: Deck, handler: @escaping (Deck) -> Void) {
        
        self.deck = deck
        self.handler = handler
        
        observation += [deck.observe(\Deck.ship_0, changeHandler: observeHandler)]
        observation += [deck.observe(\Deck.ship_1, changeHandler: observeHandler)]
        observation += [deck.observe(\Deck.ship_2, changeHandler: observeHandler)]
        observation += [deck.observe(\Deck.ship_3, changeHandler: observeHandler)]
        observation += [deck.observe(\Deck.ship_4, changeHandler: observeHandler)]
        observation += [deck.observe(\Deck.ship_5, changeHandler: observeHandler)]
        observation += [deck.observe(\Deck.ship_6, changeHandler: observeHandler)]
        
        handler(deck)
    }
    
    private func observeHandler(_: Deck, _:NSKeyValueObservedChange<Int>) {
        
        handler(deck)
    }
}

final class Fleet: NSObject {
    
    let fleetNumber: Int
    
    private var observer: DeckObserver?
    
    @objc dynamic private(set) var ships: [Ship] = []
    private var deck: Deck?
    
    let store = ServerDataStore.default
    
    init?(number: Int) {
        
        guard case 1...4 = number else {
            
            Logger.shared.log("Fleet number out of range")
            
            return nil
        }
        
        fleetNumber = number
        
        super.init()
        
        if let deck = store.sync(execute: { self.store.deck(by: number) }) {
            
            self.setupDeck(deck: deck)
            
            return
        }
        
        ServerDataStore.default
            .future { _ -> Deck? in
                
                guard let deck = self.store.sync(execute: { self.store.deck(by: number) }) else {
                    
                    return .none
                }
                
                return deck
            }
            .onSuccess { deck in
                
                self.setupDeck(deck: deck)
            }
            .onFailure { error in
                
                Logger.shared.log("\(error)")
        }
    }
    
    subscript(_ index: Int) -> Ship? {
        
        return store.sync { self.deck?[index] }
    }
    
    private func setupDeck(deck: Deck) {
        
        self.deck = deck
        self.observer = DeckObserver(deck: deck) { [weak self] in
            
            self?.setupShips(deck: $0)
        }
    }
    
    private func setupShips(deck: Deck) {
        
        ships = store.sync { deck[0...6] }
    }
}
