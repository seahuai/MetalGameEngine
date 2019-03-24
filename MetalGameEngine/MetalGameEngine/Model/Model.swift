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
    
    var tiling = 1
    
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
    }
    
}
