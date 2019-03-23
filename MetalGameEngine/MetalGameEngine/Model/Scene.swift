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
        
        renderEncoder.setFragmentBytes(&lights, length: MemoryLayout<Light>.stride * lights.count, index: Int(BufferIndexLights.rawValue))
        
        renderables.forEach{
            renderEncoder.pushDebugGroup($0.name)
            $0.render(renderEncoder: renderEncoder, uniforms: uniforms, fragmentUniforms: fragmentUniforms)
            renderEncoder.popDebugGroup()
        }
    }
}

extension Scene {
    func sceneSizeWillChange(_ size: CGSize) {
        
    }
    
    func sceneHorizontalRotate(_ translation: float2) {
        let sensitivity: Float = 0.01
        currentCamera.position = float4x4(rotationY: translation.x * sensitivity).upperLeft() * currentCamera.position
        currentCamera.rotation.y = atan2f(-currentCamera.position.x, -currentCamera.position.z)
    }
    
    func sceneRotate(_ translation: float2) {
        let sensitivity: Float = 0.01
        currentCamera.rotation.x -= Float(translation.y) * sensitivity
        currentCamera.rotation.y += Float(translation.x) * sensitivity
    }
    
    func sceneZooming(_ delta: CGFloat) {
        let sensitivity: Float = 0.01
        let cameraVector = currentCamera.modelMatrix.upperLeft().columns.2
        currentCamera.position += Float(delta) * sensitivity * cameraVector
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



