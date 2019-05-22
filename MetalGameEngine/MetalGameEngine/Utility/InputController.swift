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
}

extension InputControllerDelegate {
    func inputController(_ controller: InputController, pressKey key: Key, state: InputState) -> Bool { return true }
}

class InputController {
    
    weak var delegate: InputControllerDelegate?
    
    // 需要处理的节点
    var node: Node?
    
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
    
    func update(_ deltaTime: Float) {
        guard let player = node else { return }
        let translationSpeed = deltaTime * self.translationSpeed
        let rotationSpeed = deltaTime * self.rotationSpeed
        var direction = float3(repeating: 0)
        var rotation = float3(repeating: 0)
        for key in keys {
            switch key {
            case .w:
                direction.z += 1
            case .a:
                direction.x -= 1
            case .s:
                direction.z -= 1
            case .d:
                direction.x += 1
            case .up:
                direction.y += 1
            case .down:
                direction.y -= 1
            case .left:
                rotation.y -= rotationSpeed
            case .right:
                rotation.y += rotationSpeed
            default:
                break
            }
        }
        if rotation != [0, 0, 0] {
            let newRotation = player.rotation + rotation
            player.rotation = newRotation
        }
        
        if direction != [0, 0, 0] {
            direction = normalize(direction)
            let translationDirection = direction.z * player.forwardVector + direction.x * player.rightVector
            let translation = translationDirection * translationSpeed
            let translationY = direction.y * translationSpeed
            var newPosition = player.position + translation
            newPosition.y += translationY
            player.position = newPosition
        }
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
