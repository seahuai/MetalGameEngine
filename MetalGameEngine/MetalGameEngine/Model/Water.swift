//
//  Water.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/9.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class Water: Node {
    
    let waterNormalTexture: MTLTexture
    
    private var pipelineState: MTLRenderPipelineState!
    
    private let waterMesh: MTKMesh!
    
//    private var depthStencilState: MTLDepthStencilState!
//
//    private var refletionTexture: MTLTexture!
//    private var reflectionDepthTexture: MTLTexture!
//    private var refractionTexture: MTLTexture!
//    private var refractionDepthTexture: MTLTexture!
//
//    private var reflectionPassDescripator: MTLRenderPassDescriptor!
//    private var refractionPassDescripator: MTLRenderPassDescriptor!
    
    init(normalTextureName: String? = nil, size: float2 = [100, 100]) {
        let textureName = normalTextureName ?? "normal-water"
        guard let waterNormalTexture = Texture.loadTexture(imageNamed: textureName) else {
            fatalError()
        }
        
        self.waterNormalTexture = waterNormalTexture
        
        self.waterMesh = Geometry.plane(size: size)

        super.init()
        
        buildRenderPipelineState()
//
//        buildDepthStencilState()
//
//        initializeTextures(drawableSize)
//
//        initializePassDescripator()
    }
    
    private func buildRenderPipelineState() {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = Renderer.library?.makeFunction(name: "vertex_water")
        descriptor.fragmentFunction = Renderer.library?.makeFunction(name: "fragment_water")
        descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(waterMesh.vertexDescriptor)
        descriptor.depthAttachmentPixelFormat = .depth32Float
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        do {
            pipelineState = try Renderer.device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder,
                uniforms: Uniforms,
                fragmentUniforms: FragmentUniforms,
                reflectionTexture: MTLTexture?,
                refractionTexture: MTLTexture?) {
        
        renderEncoder.pushDebugGroup("Water")
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        renderEncoder.setVertexBuffer(waterMesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        
        var _uniforms = uniforms
        _uniforms.modelMatrix = self.modelMatrix
        renderEncoder.setVertexBytes(&_uniforms, length: MemoryLayout<Uniforms>.stride, index: Int(BufferIndexUniforms.rawValue))
        
        var _fragmentUniforms = fragmentUniforms
        renderEncoder.setFragmentBytes(&_fragmentUniforms, length: MemoryLayout<FragmentUniforms>.stride, index: Int(BufferIndexFragmentUniforms.rawValue))
        
        for submesh in waterMesh.submeshes {
            renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
        }
        
        renderEncoder.popDebugGroup()
        
    }

}

private extension Water {
    
//    func initializeTextures(_ size: CGSize) {
//        refletionTexture = Texture.newTexture(pixelFormat: .bgra8Unorm, size: size, label: "Refletion")
//        reflectionDepthTexture = Texture.newTexture(pixelFormat: .depth32Float, size: size, label: "Refletion Depth")
//
//        refractionTexture = Texture.newTexture(pixelFormat: .bgra8Unorm, size: size, label: "Refraction")
//        refractionTexture = Texture.newTexture(pixelFormat: .depth32Float, size: size, label: "Refraction Depth")
//    }
//
//    func initializePassDescripator() {
//        reflectionPassDescripator = MTLRenderPassDescriptor()
//        reflectionPassDescripator.setupColorAttachment(index: 0, texture: refletionTexture)
//        reflectionPassDescripator.setupDepthAttachment(with: reflectionDepthTexture)
//
//        refractionPassDescripator = MTLRenderPassDescriptor()
//        refractionPassDescripator.setupColorAttachment(index: 0, texture: refractionTexture)
//        refractionPassDescripator.setupDepthAttachment(with: refractionDepthTexture)
//    }
//
//    func buildDepthStencilState() {
//        let descriptor = MTLDepthStencilDescriptor()
//        descriptor.depthCompareFunction = .less
//        descriptor.isDepthWriteEnabled = true
//        depthStencilState = Renderer.device.makeDepthStencilState(descriptor: descriptor)!
//    }
}

extension Water {
    

}
