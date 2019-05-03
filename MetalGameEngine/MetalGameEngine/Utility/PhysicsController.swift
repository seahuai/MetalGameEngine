//
//  PhysicsController.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/5/2.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Foundation

class PhysicsController {
    
    var dynamicBody: Node?
    
    var staticsBodices: [Node] = []
    
    var holdAllColliedBodies = false
    
    var colliedBodies: [Node] = []
    
    func addStaticBody(_ body: Node) {
        removeStaticBody(body)
        staticsBodices.append(body)
    }
    
    func removeStaticBody(_ body: Node) {
        guard let index = staticsBodices.index(of: body) else { return }
        staticsBodices.remove(at: index)
    }
    
    func checkCollisions() -> Bool {
        colliedBodies = []
        guard let dynamicBody = self.dynamicBody else { return false }
        let dynamicBodyRadius = max((dynamicBody.size.x / 2), (dynamicBody.size.z / 2))
        let dynamicBodyPosition = dynamicBody.worldTransform.columns.3.xyz
        for body in staticsBodices {
            if body == dynamicBody { continue }
            let bodyRadius = max((body.size.x / 2), (body.size.z / 2))
            let bodyPosition = body.worldTransform.columns.3.xyz
            let d = distance(dynamicBodyPosition, bodyPosition)
            if d < (dynamicBodyRadius + bodyRadius) {
                // 碰撞了
                if holdAllColliedBodies {
                    colliedBodies.append(body)
                } else {
                    return true
                }
            }
        }
        return !colliedBodies.isEmpty
    }
    
}

