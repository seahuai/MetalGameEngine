//
//  Scene.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/19.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Metal

// 以Scene为单位，每个场景单独渲染自己的光照和模型
class Scene {
    
    var cameras: [Camara] = []
    var currentCameraIndex = 0
    var currentCamera: Camara {
        return cameras[currentCameraIndex]
    }
    
    var lights: [Light] = []
    
    private var renderables: [Renderable] = []
    
    func render(renderEncoder: MTLRenderCommandEncoder) {
        
        var uniforms = Uniforms()
        uniforms.viewMatrix = currentCamera.viewMatrix
        uniforms.projectionMatrix = currentCamera.projectionMatrix
        
        var fragmentUniforms = FragmentUniforms()
        fragmentUniforms.lightCount = uint(lights.count)
        fragmentUniforms.cameraPosition = currentCamera.position
        fragmentUniforms.tiling = 1
        
        renderEncoder.setFragmentBytes(&fragmentUniforms, length: MemoryLayout<FragmentUniforms>.stride, index: Int(BufferIndexFragmentUniforms.rawValue))
        
        renderEncoder.setFragmentBytes(&lights, length: MemoryLayout<Light>.stride * lights.count, index: Int(BufferIndexLights.rawValue))
        
        renderables.forEach{
            renderEncoder.pushDebugGroup($0.name)
            $0.render(renderEncoder: renderEncoder, uniforms: uniforms)
            renderEncoder.popDebugGroup()
        }
    }

}

extension Scene {
    func add(node: Node) {
        var nodes: [Node] = []
        nodes.append(node)
        nodes.append(contentsOf: node.children)
        
        for _node in nodes {
            if let model = _node as? Model {
                let prop = Prop(model: model)
                renderables.append(prop)
            }
        }
    }
    
    func remove(node: Node) {
        var nodes: [Node] = []
        nodes.append(node)
        nodes.append(contentsOf: node.children)
        
        for _node in nodes {
            if let index = (renderables.index{ $0.identifier == _node.identifier }) {
                renderables.remove(at: index)
            }
        }
    }
}



