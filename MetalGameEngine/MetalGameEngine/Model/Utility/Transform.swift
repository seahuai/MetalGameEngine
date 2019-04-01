//
//  Transform.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/1.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Foundation

struct Transform {
    var position: float3 = [0, 0, 0]
    var rotation: float3 = [0, 0, 0]
    var scale: float3 = [1, 1, 1]
    
    init(node: Node) {
        position = node.position
        rotation = node.rotation
        scale = node.scale
    }
    
    var modelMatrix: float4x4 {
        let translateMatrix = float4x4(translation: position)
        let rotateMatrix = float4x4(rotation: rotation)
        let scaleMatrix = float4x4(scaling: scale)
        return translateMatrix * rotateMatrix * scaleMatrix
    }
    
    var normalMatrix: float3x3 {
        return float3x3(normalFrom4x4: modelMatrix)
    }
}
