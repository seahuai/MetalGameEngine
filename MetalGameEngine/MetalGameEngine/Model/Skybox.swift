//
//  Skybox.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/24.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class Skybox {
    
    let mesh: MTKMesh
    
    let pipelineState: MTLRenderPipelineState
    
    let depthStencilState: MTLDepthStencilState
    
    var texture: MTLTexture?
    
    init?(textureName: String?) {
        let alloctor = MTKMeshBufferAllocator(device: Renderer.device)
        let cube = MDLMesh(boxWithExtent: [1, 1, 1], segments: [1, 1, 1], inwardNormals: true, geometryType: .triangles, allocator: alloctor)
        
        do {
            mesh = try MTKMesh(mesh: cube, device: Renderer.device)
        } catch {
            return nil
        }
        
        if let name = textureName {
            texture = Texture.loadCubeTexture(imageName: name)
        }
        
        pipelineState = Skybox.buildPipelineState(cube.vertexDescriptor)
        
        depthStencilState = Skybox.buildDepthStencilState()
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, uniforms: Uniforms) {
        renderEncoder.pushDebugGroup("Skybox")
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthStencilState)
        
        renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        
        var viewMatrix = uniforms.viewMatrix
        // 防止天空盒移动
        viewMatrix.columns.3 = [0, 0, 0, 1]
        
        var viewProjectionMatrix = uniforms.projectionMatrix * viewMatrix
        renderEncoder.setVertexBytes(&viewProjectionMatrix, length: MemoryLayout<float4x4>.stride, index: 1)
        
        renderEncoder.setFragmentTexture(texture, index: 0)
        
        let submesh = mesh.submeshes[0]
        renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: 0)
        
        renderEncoder.popDebugGroup()
    }
}

extension Skybox {
    private class func buildPipelineState(_ vertexDescrptor: MDLVertexDescriptor) -> MTLRenderPipelineState {
        let desciptor = MTLRenderPipelineDescriptor()
        
        desciptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
        desciptor.depthAttachmentPixelFormat = .depth32Float
        desciptor.vertexFunction = Renderer.library?.makeFunction(name: "vertex_skybox")
        desciptor.fragmentFunction = Renderer.library?.makeFunction(name: "fragment_skybox")
        desciptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescrptor)
        let pipelineState: MTLRenderPipelineState
        
        do {
            pipelineState = try Renderer.device.makeRenderPipelineState(descriptor: desciptor)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        return pipelineState
    }
    
    private class func buildDepthStencilState() -> MTLDepthStencilState {
        let desciptor = MTLDepthStencilDescriptor()
        desciptor.depthCompareFunction = .lessEqual
        desciptor.isDepthWriteEnabled = true
        let depthStencilState = Renderer.device.makeDepthStencilState(descriptor: desciptor)
        return depthStencilState!
    }
}
