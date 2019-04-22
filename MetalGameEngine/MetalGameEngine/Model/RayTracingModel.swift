//
//  RayTracingModel.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/22.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class RayTracingModel: Node {
    
    let mesh: MTKMesh
    var submeshes: [Submesh] = []
    
    var fileName: String?
    
    var vertexDescriptor: MDLVertexDescriptor =  {
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[0] =
            MDLVertexAttribute(name: MDLVertexAttributePosition,
                               format: .float3,
                               offset: 0, bufferIndex: 0)
        vertexDescriptor.attributes[1] =
            MDLVertexAttribute(name: MDLVertexAttributeNormal,
                               format: .float3,
                               offset: 0, bufferIndex: 1)
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)
        vertexDescriptor.layouts[1] = MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)
        return vertexDescriptor
    }()
    
    
    init?(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ".obj") else { return nil }
        
        let alloctor = MTKMeshBufferAllocator(device: Renderer.device)
        let asset = MDLAsset(url: url, vertexDescriptor: self.vertexDescriptor, bufferAllocator: alloctor)
        let mdlMesh = asset.object(at: 0) as! MDLMesh
        
        do {
            mesh = try MTKMesh(mesh: mdlMesh, device: Renderer.device)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        super.init()
        
        submeshes = mdlMesh.submeshes?.enumerated().compactMap({ (index, submesh) in
            (submesh as? MDLSubmesh).map{
                Submesh(mtkSubmesh: mesh.submeshes[index], mdlsubmesh: $0, vertexDescriptor: self.vertexDescriptor)
            }
        }) ?? []
        
        self.boundingBox = mdlMesh.boundingBox
        self.name = name
        self.fileName = name
    }

}
