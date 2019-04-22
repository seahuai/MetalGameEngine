//
//  Scene.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/19.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Metal

protocol SceneDelegate: class {
    func scene(_ scene: Scene, didChangeModels models: [Model])
    func scene(_ scnee: Scene, didChangeLights lights: [Light])
    func scene(_ scene: Scene, didChangeRayTracingModels: [RayTracingModel])
}

extension SceneDelegate {
    // 可选方法
    func scene(_ scene: Scene, didChangeModels models: [Model]) {}
    func scene(_ scnee: Scene, didChangeLights lights: [Light]) {}
    func scene(_ scene: Scene, didChangeRayTracingModels: [RayTracingModel]) {}
}

// 以Scene为单位，每个场景单独渲染自己的光照和模型
class Scene {
    
    // MARK: - Pubild Variable
    var name: String = "untitled"
    var nodes: [Node] = []
    var skybox: Skybox?
    var terrains: [Terrain] = []
    var cameras: [Camera] = []
    var currentCameraIndex = 0
    var currentCamera: Camera? {
        // 防止越界
        let contain = cameras.indices.contains(currentCameraIndex)
        return contain ? cameras[currentCameraIndex] : nil
    }
    
    var lights: [Light] = [] {
        didSet {
            delegate?.scene(self, didChangeLights: self.lights)
        }
    }
    
    weak var delegate: SceneDelegate? {
        didSet {
            self.delegate?.scene(self, didChangeModels: self.models)
            self.delegate?.scene(self, didChangeLights: self.lights)
            self.delegate?.scene(self, didChangeRayTracingModels: self.rayTracingModels)
        }
    }
    
    // MARK: - Private Variable
    private var models: [Model] = []
    private var rayTracingModels: [RayTracingModel] = []
    private var waters: [Water] = []
    
    
    // MARK: - Compute Variable
    var uniforms: Uniforms {
        var uniforms = Uniforms()
        uniforms.clipPlane = [0, -1, 0, 100];
        
        if let currentCamera = currentCamera {
            uniforms.viewMatrix = currentCamera.viewMatrix
            uniforms.projectionMatrix = currentCamera.projectionMatrix
        }
        
        return uniforms
    }
    
    var fragmentUniforms: FragmentUniforms {
        var fragmentUniforms = FragmentUniforms()
        fragmentUniforms.lightCount = uint(lights.count)
        fragmentUniforms.tiling = 1
        
        if let currentCamera = currentCamera {
            fragmentUniforms.cameraPosition = currentCamera.position
        }
        
        return fragmentUniforms
    }

}

// MARK: - Public Method
extension Scene {
    
    struct VerticesBuffer {
        let triangleCount: Int
        let positionsBuffer: MTLBuffer
        let normalsBuffer: MTLBuffer
        let colorsBuffer: MTLBuffer
    }
    
    func props(type: RendererType) -> [Prop] {
        let props: [Prop] = self.models.map{
            return Prop(model: $0, type: type)
        }
        return props
    }
    
    func rayTracingUsedBuffer() -> VerticesBuffer? {
        guard !rayTracingModels.isEmpty else { return nil }
        
        var positions: [float3] = []
        var normals: [float3] = []
        var colors: [float3] = []
        // 遍历所有 Model
        for model in rayTracingModels {
            // 取出 mesh buffer 中的数据重新处理
            let mesh = model.mesh
            let count = mesh.vertexCount
            let positionsBuffer = mesh.vertexBuffers[0].buffer
            let normalsBuffer = mesh.vertexBuffers[1].buffer
            let positionPoninter = positionsBuffer.contents().bindMemory(to: float3.self, capacity: count)
            let normalPointer = normalsBuffer.contents().bindMemory(to: float3.self, capacity: count)
            for submesh in model.submeshes {
                let mtksubmesh = submesh.mtkSubmesh
                let indexCount = mtksubmesh.indexCount
                let indexBuffer = mtksubmesh.indexBuffer.buffer
                // 从 submesh 中取数据需要先做偏移
                let offset = mtksubmesh.indexBuffer.offset
                let indexPointer = indexBuffer.contents().advanced(by: offset)
                var indices = indexPointer.bindMemory(to: uint32.self, capacity: indexCount)
                for _ in 0..<indexCount {
                    let index = Int(indices.pointee)
                    // TODO: 需要做坐标空间的转换
                    let position = positionPoninter[index] + model.position
                    positions.append(position)
                    normals.append(normalPointer[index])
                    indices = indices.advanced(by: 1)
                    
                    // 暂时只传颜色用于测试
                    let baseColor = submesh.material.baseColor
                    colors.append(baseColor)
                }
            }
        }
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU not available")
        }
        
        // 如果没有顶点数据则直接返回
        guard !positions.isEmpty else { return nil }
        
        guard
            let positionsBuffer = device.makeBuffer(bytes: positions, length: MemoryLayout<float3>.stride * positions.count, options: []),
            let normalsBuffer = device.makeBuffer(bytes: normals, length: MemoryLayout<float3>.stride * normals.count, options: []),
            let colorsBuffer = device.makeBuffer(bytes: colors, length: MemoryLayout<float3>.stride * colors.count, options: [])
            else { return nil }
        
        return VerticesBuffer(triangleCount: positions.count / 3, positionsBuffer: positionsBuffer, normalsBuffer: normalsBuffer, colorsBuffer: colorsBuffer)
    }
}

// MARK: - Handle Node
extension Scene {
    func add(node: Node, parentNode: Node? = nil) {
        if let parentNode = parentNode {
            parentNode.add(node)
            let isContain = contain(node: parentNode)
            if isContain {
                _add(node: node)
            } else {
                add(node: parentNode)
            }
        } else {
            var allNodes: [Node] = []
            nodes.append(node)
            allNodes.append(node)
            allNodes.append(contentsOf: node.children)
            for _node in allNodes {
                _add(node: _node)
            }
        }
        
    }
    
    func remove(node: Node) {
        if let index = nodes.firstIndex(of: node) {
            nodes.remove(at: index)
            _remove(node: node)
        } else {
            node.parent?.remove(node)
            _remove(node: node)
        }
    }
    
    private func _add(node: Node) {
        if let model = node as? Model {
            models.append(model)
            delegate?.scene(self, didChangeModels: models)
        }
        
        if let model = node as? RayTracingModel {
            rayTracingModels.append(model)
            delegate?.scene(self, didChangeRayTracingModels: rayTracingModels)
        }
        
        if let water = node as? Water {
            waters.append(water)
        }
        
        if let camera = node as? Camera {
            cameras.append(camera)
        }
        
        if let terrain = node as? Terrain {
            terrains.append(terrain)
        }
    }
    
    private func _remove(node: Node) {
        
        if node.parent == nil {
            for _node in node.children {
                _remove(node: _node)
            }
        }
        
        if let model = node as? Model {
            guard let index = models.firstIndex(of: model) else { return }
            models.remove(at: index)
            delegate?.scene(self, didChangeModels: models)
        }
        
        if let model = node as? RayTracingModel {
            guard let index = rayTracingModels.firstIndex(of: model) else { return }
            rayTracingModels.remove(at: index)
            delegate?.scene(self, didChangeRayTracingModels: rayTracingModels)
        }
        
        if let water = node as? Water {
            guard let index = waters.firstIndex(of: water) else { return }
            waters.remove(at: index)
        }
        
        if let camera = node as? Camera {
            guard let index = cameras.firstIndex(of: camera) else { return }
            cameras.remove(at: index)
        }
        
        if let terrain = node as? Terrain {
            guard let index = terrains.firstIndex(of: terrain) else { return }
            terrains.remove(at: index)
        }
    }
    
    private func contain(node: Node) -> Bool {
        for parentNode in nodes {
            if parentNode == node {
                return true
            }
            
            if parentNode.contain(node: node) {
                return true
            }
        }
        return false
    }
}

// MARK: - Scene
extension Scene {
    func sceneSizeWillChange(_ size: CGSize) {
        guard let currentCamera = currentCamera else { return }
        currentCamera.aspect = Float(size.width)/Float(size.height)
    }
    
    func sceneHorizontalRotate(_ translation: float2) {
        guard let currentCamera = currentCamera else { return }
        let sensitivity: Float = 0.01
        currentCamera.isHorizontalRotate = true
        currentCamera.position = float4x4(rotationY: translation.x * sensitivity).upperLeft() * currentCamera.position
        currentCamera.rotation.y = atan2f(-currentCamera.position.x, -currentCamera.position.z)
    }
    
    func sceneRotate(_ translation: float2) {
        guard let currentCamera = currentCamera else { return }
        let sensitivity: Float = 0.01
        currentCamera.isHorizontalRotate = false
        currentCamera.rotation.x += Float(translation.y) * sensitivity
        currentCamera.rotation.y -= Float(translation.x) * sensitivity
    }
    
    func sceneZooming(_ delta: CGFloat) {
        guard let currentCamera = currentCamera else { return }
        let sensitivity: Float = 0.01
        if currentCamera.isHorizontalRotate {
            let cameraVector = currentCamera.modelMatrix.upperLeft().columns.2
            currentCamera.position += Float(delta) * sensitivity * cameraVector
        } else {
            currentCamera.position.z += Float(delta) * sensitivity
        }
        
    }
}


// TODO: need to remove
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



