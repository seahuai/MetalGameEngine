//
//  InputController.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/29.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

protocol InputControllerDelegate: class {
    func inputController(_ controller: InputController, pressKey key: Key, state: InputState) -> Bool
    func inputController(_ controller: InputController, handleKey key: Key)
}

class InputController {
    
    weak var delegate: InputControllerDelegate?
    
    // 移动速率和旋转速率
    var translationSpeed: Float = 1.0
    var rotationSpeed: Float = 1.0
    
    private var keys: Set<Key> = []
    
    // 接收键盘输入
    func processKey(_ key: Key, state: InputState) {
        let isOk = delegate?.inputController(self, pressKey: key, state: state) ?? true
        if !isOk { return }
        switch state {
        case .began:
            keys.insert(key)
        case .ended:
            keys.remove(key)
        default:
            break
        }
    }
    
    func update(_ deltaTime: TimeInterval) {
        let key = keys.removeFirst()
        delegate?.inputController(self, handleKey: key)
    }
}


// MARK: - Keys Input
extension GameView {
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

// MARK: - Enum
enum Key: UInt16 {
    case w =      13
    case s =      1
    case a =      0
    case d =      2
    case up =     126
    case down =   125
    case left =   123
    case right =  124
    case space =  49
//    case q =      12
//    case e =      14
//    case key1 =   18
//    case key2 =   19
//    case key0 =   29
//    case c =      8
}


enum InputState {
    case began, moved, ended, cancelled, continued
}
