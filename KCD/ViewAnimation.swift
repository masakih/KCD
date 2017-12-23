//
//  ViewAnimation.swift
//  KCD
//
//  Created by Hori,Masaki on 2017/12/23.
//  Copyright © 2017年 Hori,Masaki. All rights reserved.
//

import Cocoa

protocol ViewAnimationTerget {}
extension NSView: ViewAnimationTerget {}
extension NSWindow: ViewAnimationTerget {}

struct ViewAnimationAttributes {
    
    private(set) var animations: [NSViewAnimation.Key: Any]
    
    init(target: ViewAnimationTerget, startFrame: NSRect? = nil, endFrame: NSRect? = nil, effect: NSViewAnimation.EffectName? = nil ) {
        
        animations = [.target: target]
        animations[.startFrame] = startFrame
        animations[.endFrame] = endFrame
        animations[.effect] = effect
    }
    
    var startFrame: NSRect? {
        get { return animations[.startFrame] as? NSRect }
        set { animations[.startFrame] = newValue }
    }
    
    var endFrame: NSRect? {
        get { return animations[.endFrame] as? NSRect }
        set { animations[.endFrame] = newValue }
    }
    
    var effect: NSViewAnimation.EffectName? {
        get { return animations[.effect] as? NSViewAnimation.EffectName }
        set { animations[.effect] = newValue }
    }
}

class ViewAnimation: NSViewAnimation, NSAnimationDelegate {
    
    var completeHandler: (() -> Void)?
    
    init(viewAnimations: [ViewAnimationAttributes]) {
        
        super.init(viewAnimations: viewAnimations.map { $0.animations })
    }
    
    required init?(coder: NSCoder) {
        fatalError("Can not initialize with NSCoder")
    }
    
    func start(completeHandler: @escaping () -> Void) {
        
        delegate = self
        self.completeHandler = completeHandler
        
        start()
    }
    
    ///
    func animationDidEnd(_ animation: NSAnimation) {
        
        completeHandler?()
    }
}
