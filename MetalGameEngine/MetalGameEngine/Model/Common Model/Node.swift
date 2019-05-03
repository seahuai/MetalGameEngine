//
//  Node.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/19.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class Node {
    
    let identifier = UUID().uuidString
    
    var name = "untitled"
    // 位置
    var position: float3 = [0, 0, 0]
    // 旋转
    var rotation: float3 = [0, 0, 0]
    // 缩放
    var scale: float3 = [1, 1, 1]
    
    // 尺寸
    var boundingBox = MDLAxisAlignedBoundingBox()
    var size: float3 {
        return boundingBox.maxBounds - boundingBox.minBounds
    }
    
    // 碰撞检测相关
    var isCheckingCollide = false
    
    // 模型矩阵
    var modelMatrix: float4x4 {
        let translationMatrix = float4x4(translation: position)
        let rotationMatrix = float4x4(rotation: rotation)
        let scaleMatrix = float4x4(scaling: scale)
        return translationMatrix * rotationMatrix * scaleMatrix
    }
    
    
    // 树形结构管理Node
    var parent: Node?
    var children: [Node] = []
    
    var subNodes: [Node] {
        var nodes: [Node] = []
        
        if children.isEmpty {
            return []
        }
        
        for child in children {
            nodes.append(child)
            nodes.append(contentsOf: child.subNodes)
        }
        return nodes
    }
    
    var worldTransform: float4x4 {
        if let parent = parent {
           return parent.worldTransform * self.modelMatrix
        }
        return modelMatrix
    }
    
    var forwardVector: float3 {
        return normalize([sin(rotation.y), 0, cos(rotation.y)])
    }
    
    var rightVector: float3 {
        return [forwardVector.z, forwardVector.y, -forwardVector.x]
    }
    
    final func add(_ node: Node) {
        children.append(node)
        node.parent = self
    }
    
    final func remove(_ node: Node) {
        for child in node.children {
            child.parent = self
            children.append(child)
        }
        node.children = []
        guard let index = (children.firstIndex { $0 === node }) else { return }
        children.remove(at: index)
    }
    
    final func contain(node: Node) -> Bool {
        return subNodes.contains(node)
    }
    
}

extension Node: Equatable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
