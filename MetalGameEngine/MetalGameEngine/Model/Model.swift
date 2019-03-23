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
    
    private static var defaultVertexDescriptor: MDLVertexDescriptor = {
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
    let submeshes: [Submesh]
    
    private let vertexFunctionName: String
    private let fragmentFunctionName: String
    
    init?(name: String,
          vertexFunctionName: String = "vertex_main",
          fragmentFunctionName: String = "fragment_PBR") {
        guard let url = Bundle.main.url(forResource: name, withExtension: ".obj") else { return nil }
        
        self.vertexFunctionName = vertexFunctionName
        self.fragmentFunctionName = fragmentFunctionName
        
        let alloctor = MTKMeshBufferAllocator(device: Renderer.device)
        let asset = MDLAsset(url: url, vertexDescriptor: Model.defaultVertexDescriptor, bufferAllocator: alloctor)
        let mdlMesh = asset.object(at: 0) as! MDLMesh
        
        mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate, tangentAttributeNamed: MDLVertexAttributeTangent, bitangentAttributeNamed: MDLVertexAttributeBitangent)
        
        // 更新vertexDescriptor
        Model.defaultVertexDescriptor = mdlMesh.vertexDescriptor
        
        var mesh: MTKMesh
        
        do {
            mesh = try MTKMesh(mesh: mdlMesh, device: Renderer.device)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        self.mesh = mesh
        vertexBuffer = mesh.vertexBuffers[0].buffer
        
        submeshes = mdlMesh.submeshes?.enumerated().compactMap({ (index, submesh) in
            (submesh as? MDLSubmesh).map{
                Submesh(mtkSubmesh: mesh.submeshes[index], mdlsubmesh: $0, vertexDescriptor: Model.defaultVertexDescriptor)
            }
        }) ?? []
        
        super.init()
        
        self.boundingBox = mdlMesh.boundingBox
        self.name = name
    }
    
    func setNeedsToRender() {
        submeshes.forEach{
            $0.setNeedsToRender(vertexFunctionName: vertexFunctionName,
                                fragmentFunctionName: fragmentFunctionName)
        }
    }
    
}
