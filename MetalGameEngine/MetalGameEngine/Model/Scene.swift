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
    
    var shadowTexture: MTLTexture?
    
    var nodes: [Node] = []
    
    var cameras: [Camera] = []
    var currentCameraIndex = 0
    var currentCamera: Camera {
        return cameras[currentCameraIndex]
    }
    
    var lights: [Light] = [] {
        didSet {
            lightsChangeNotificationBlock?(lights)
        }
    }
    var lightsChangeNotificationBlock: (([Light]) -> ())?
    
    private var models: [Model] = []
    var modelsChangeNotificationBlock: (([Model]) -> ())?
    
    private var waters: [Water] = []
    
    var skybox: Skybox?
    
    var terrain: Terrain?
    
    var uniforms: Uniforms {
        var uniforms = Uniforms()
        uniforms.viewMatrix = currentCamera.viewMatrix
        uniforms.projectionMatrix = currentCamera.projectionMatrix
        uniforms.clipPlane = [0, -1, 0, 100];
        return uniforms
    }
    
    var fragmentUniforms: FragmentUniforms {
        var fragmentUniforms = FragmentUniforms()
        fragmentUniforms.lightCount = uint(lights.count)
        fragmentUniforms.cameraPosition = currentCamera.position
        fragmentUniforms.tiling = 1
        return fragmentUniforms
    }
    
    func props(type: RendererType) -> [Prop] {
        let props: [Prop] = self.models.map{
            return Prop(model: $0, type: type)
        }
        return props
    }
}

extension Scene {
    func renderWaters(renderEncoder: MTLRenderCommandEncoder, reflectionTexture: MTLTexture?, refractionTexture: MTLTexture?) {
        guard !waters.isEmpty else { return }
        
        for water in waters {
            water.render(renderEncoder: renderEncoder,
                         uniforms: self.uniforms,
                         fragmentUniforms: self.fragmentUniforms,
                         reflectionTexture: reflectionTexture,
                         refractionTexture: refractionTexture)
        }
    }
}

extension Scene {
    func sceneSizeWillChange(_ size: CGSize) {
        currentCamera.aspect = Float(size.width)/Float(size.height)
    }
    
    func sceneHorizontalRotate(_ translation: float2) {
        let sensitivity: Float = 0.01
        currentCamera.isHorizontalRotate = true
        currentCamera.position = float4x4(rotationY: translation.x * sensitivity).upperLeft() * currentCamera.position
        currentCamera.rotation.y = atan2f(-currentCamera.position.x, -currentCamera.position.z)
    }
    
    func sceneRotate(_ translation: float2) {
        let sensitivity: Float = 0.01
        currentCamera.isHorizontalRotate = false
        currentCamera.rotation.x += Float(translation.y) * sensitivity
        currentCamera.rotation.y -= Float(translation.x) * sensitivity
    }
    
    func sceneZooming(_ delta: CGFloat) {
        let sensitivity: Float = 0.01
        if currentCamera.isHorizontalRotate {
            let cameraVector = currentCamera.modelMatrix.upperLeft().columns.2
            currentCamera.position += Float(delta) * sensitivity * cameraVector
        } else {
            currentCamera.position.z += Float(delta) * sensitivity
        }
    
    }
}

extension Scene {
    func add(node: Node) {
        nodes.append(node)
        nodes.append(contentsOf: node.children)
        
        for _node in nodes {
            if let model = _node as? Model {
                models.append(model)
                modelsChangeNotificationBlock?(models)
            }
            
            if let water = _node as? Water {
                waters.append(water)
            }
        }
    }
    
    func remove(node: Node) {
        if let index = nodes.index(of: node) {
            nodes.remove(at: index)
            
            if let model = node as? Model {
                guard let index = models.index(of: model) else { return }
                models.remove(at: index)
                modelsChangeNotificationBlock?(models)
            }
            
            if let water = node as? Water {
                guard let index = waters.index(of: water) else { return }
                waters.remove(at: index)
            }
        }
    }

    
}



