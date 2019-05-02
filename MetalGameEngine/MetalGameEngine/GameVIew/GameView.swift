//
//  GameView.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/29.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class GameView: MTKView {
    var inputController: InputController?
    var physicsController: PhysicsController?
}

// MARK: - Keys Input
extension GameView {
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    open override func keyDown(with event: NSEvent) {
        guard let key = Key(rawValue: event.keyCode) else { return }
        let state: InputState = event.isARepeat ? .continued : .began
        inputController?.processKey(key, state: state)
    }
    
    open override func keyUp(with event: NSEvent) {
        guard let key = Key(rawValue: event.keyCode) else { return }
        inputController?.processKey(key, state: .ended)
    }
}
