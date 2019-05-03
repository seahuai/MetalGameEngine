//
//  Model.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/19.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

// 负责加载，不负责渲染

class Model: Node {
    
    static let defaultVertexDescriptor: MDLVertexDescriptor = {
        let floatSize = MemoryLayout<Float>.size
        
        let vertexDescriptor = MDLVertexDescriptor()
        
        vertexDescriptor.attributes[Int(Position.rawValue)] = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: 0)
        vertexDescriptor.attributes[Int(Normal.rawValue)] = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: floatSize * 3, bufferIndex: 0)
        vertexDescriptor.attributes[Int(UV.rawValue)] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: .float2, offset: floatSize * 6, bufferIndex: 0)
        
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: floatSize * 8)
        
        return vertexDescriptor
    }()
    
    var defaultVertexDescriptor: MDLVertexDescriptor = {
        let floatSize = MemoryLayout<Float>.size
        
        let vertexDescriptor = MDLVertexDescriptor()
        
        vertexDescriptor.attributes[Int(Position.rawValue)] = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: 0)
        vertexDescriptor.attributes[Int(Normal.rawValue)] = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: floatSize * 3, bufferIndex: 0)
        vertexDescriptor.attributes[Int(UV.rawValue)] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: .float2, offset: floatSize * 6, bufferIndex: 0)
        
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: floatSize * 8)
        
        return vertexDescriptor
    }()
    
    var fileName: String?
    
    var tiling = 1
    var instanceCount = 1 {
        didSet {
            initializeTransformBuffer()
        }
    }
    
    var transforms: [Transform] = []
    var instanceUniformBuffer: MTLBuffer!
    
    let vertexBuffer: MTLBuffer
    let mesh: MTKMesh
    var submeshes: [Submesh] = []
    
    init?(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ".obj") else { return nil }
        
        let alloctor = MTKMeshBufferAllocator(device: Renderer.device)
        let asset = MDLAsset(url: url, vertexDescriptor: self.defaultVertexDescriptor, bufferAllocator: alloctor)
        let mdlMesh = asset.object(at: 0) as! MDLMesh
        
        mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate, tangentAttributeNamed: MDLVertexAttributeTangent, bitangentAttributeNamed: MDLVertexAttributeBitangent)
        
        // 更新vertexDescriptor
        self.defaultVertexDescriptor = mdlMesh.vertexDescriptor
        
        var mesh: MTKMesh
        
        do {
            mesh = try MTKMesh(mesh: mdlMesh, device: Renderer.device)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        self.mesh = mesh
        vertexBuffer = mesh.vertexBuffers[0].buffer
    
        super.init()
        
        submeshes = mdlMesh.submeshes?.enumerated().compactMap({ (index, submesh) in
            (submesh as? MDLSubmesh).map{
                Submesh(mtkSubmesh: mesh.submeshes[index], mdlsubmesh: $0, vertexDescriptor: self.defaultVertexDescriptor)
            }
        }) ?? []
        
        self.boundingBox = mdlMesh.boundingBox
        self.name = name
        self.fileName = name
        
        initializeTransformBuffer()
    }
    
    override var position: float3 {
        didSet {
            updateCurrentTransform()
        }
    }
    
    override var rotation: float3 {
        didSet {
            updateCurrentTransform()
        }
    }
    
    override var scale: float3 {
        didSet {
            updateCurrentTransform()
        }
    }
    
    func update(transform: Transform, at index: Int) {
        guard index < transforms.count else {
            return
        }
        
        transforms[index] = transform
        
        var pointer = instanceUniformBuffer.contents().bindMemory(to: InstanceUniforms.self, capacity: transforms.count)
        pointer = pointer.advanced(by: index)
        pointer.pointee.modelMatrix = transform.modelMatrix
        pointer.pointee.normalMatrix = transform.normalMatrix
    }
    
    private func updateCurrentTransform() {
        let transform = Transform()
        update(transform: transform, at: 0)
    }
}

extension Model {
    
    private func initializeTransformBuffer() {
        let oldInstancesCount = transforms.count
        
        if oldInstancesCount < instanceCount {
            let defalutTransform = Transform()
            let newTransformsCount = instanceCount - oldInstancesCount
            let newTransforms = [Transform].init(repeating: defalutTransform, count: newTransformsCount)
            transforms.append(contentsOf: newTransforms)
        } else {
            let removedTransformsCount = oldInstancesCount - instanceCount
            transforms.removeLast(removedTransformsCount)
        }
        
        let instanceUniforms = transforms.map{
            InstanceUniforms(modelMatrix: $0.modelMatrix, normalMatrix: $0.normalMatrix)
        }
        
        guard let buffer = Renderer.device.makeBuffer(bytes: instanceUniforms, length: MemoryLayout<InstanceUniforms>.stride * instanceUniforms.count, options: []) else {
            fatalError()
        }
        
        instanceUniformBuffer = buffer
    }
    
}
