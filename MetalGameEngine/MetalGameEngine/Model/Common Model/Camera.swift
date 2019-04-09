//
//  Camera.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/19.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class Camara: Node {
    
    var copy: Camara {
        let camera = Camara()
        camera.position = self.position
        camera.rotation = self.position
        camera.scale = self.scale
        return camera
    }
    
    var fovDegrees: Float = 70
    var aspect: Float = 1
    var near: Float = 0.001
    var far: Float = 100
    var fovRadians: Float {
        return radians(fromDegrees: fovDegrees)
    }
    
    var isHorizontalRotate = false
    
    // 投影矩阵
    var projectionMatrix: float4x4 {
        return float4x4(projectionFov: fovRadians, near: near, far: far, aspect: aspect)
    }
    
    // 视点矩阵
    var horizontalRotateViewMatrix: float4x4 {
        let translateMatrix = float4x4(translation: position)
        let rotateMatrix = float4x4(rotation: rotation)
        let scaleMatrix = float4x4(scaling: scale)
        return (translateMatrix * scaleMatrix * rotateMatrix).inverse
    }
    
    var rotateViewMatrix: float4x4 {
        let translateMatrix = float4x4(translation: position).inverse
        let rotateMatrix = float4x4(rotation: rotation)
        let scaleMatrix = float4x4(scaling: scale)
        return translateMatrix * scaleMatrix * rotateMatrix
    }
    
    var viewMatrix: float4x4 {
        return isHorizontalRotate ? horizontalRotateViewMatrix : rotateViewMatrix
    }
}
