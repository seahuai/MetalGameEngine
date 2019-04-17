//
//  Water.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/9.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class Water: Node {
    
    var color = float4(0.0, 0.3, 0.5, 0.1)
    
    var timer: Float = 0
    
    static var reflectionPass: RenderPass?
    static var refractionPass: RenderPass?
    
    private let waterNormalTexture: MTLTexture
    private var underWaterTexture: MTLTexture?
    private var pipelineState: MTLRenderPipelineState!
    private let waterMesh: MTKMesh!
    
    init(normalTextureName: String? = nil,
         underWaterTextureName: String? = nil,
         size: float2 = [100, 100]) {
        
        let normalTextureName = normalTextureName ?? "normal-water"
        
        guard let waterNormalTexture = Texture.loadTexture(imageNamed: normalTextureName) else {
            fatalError()
        }
        
        self.waterNormalTexture = waterNormalTexture
        
        self.waterMesh = Geometry.plane(size: size)

        super.init()
        
        if let underWaterTextureName = underWaterTextureName {
            let texture = Texture.loadTexture(imageNamed: underWaterTextureName)
            self.underWaterTexture = texture
        }
        
        buildRenderPipelineState()
    }
    
    private func buildRenderPipelineState() {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = Renderer.library?.makeFunction(name: "vertex_water")
        descriptor.fragmentFunction = Renderer.library?.makeFunction(name: "fragment_water")
        descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(waterMesh.vertexDescriptor)
        descriptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
        descriptor.depthAttachmentPixelFormat = Renderer.depthPixelFormat
        
        descriptor.colorAttachments[0].isBlendingEnabled = true
        descriptor.colorAttachments[0].rgbBlendOperation = .add
        descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        
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
        
        timer += 0.001
        
        var refractionTexture = refractionTexture
        if let underWaterTexture = self.underWaterTexture {
            refractionTexture = underWaterTexture
        }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        renderEncoder.setVertexBuffer(waterMesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        
        var _uniforms = uniforms
        _uniforms.modelMatrix = self.modelMatrix
        renderEncoder.setVertexBytes(&_uniforms, length: MemoryLayout<Uniforms>.stride, index: Int(BufferIndexUniforms.rawValue))
        
        var _fragmentUniforms = fragmentUniforms
        renderEncoder.setFragmentBytes(&_fragmentUniforms, length: MemoryLayout<FragmentUniforms>.stride, index: Int(BufferIndexFragmentUniforms.rawValue))
        renderEncoder.setFragmentBytes(&color, length: MemoryLayout<float4>.stride, index: 0)
        renderEncoder.setFragmentBytes(&timer, length: MemoryLayout<Float>.size, index: 1)
        
        renderEncoder.setFragmentTexture(waterNormalTexture, index: 0)
        renderEncoder.setFragmentTexture(reflectionTexture, index: 1)
        renderEncoder.setFragmentTexture(refractionTexture, index: 2)
        
        for submesh in waterMesh.submeshes {
            renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
        }
        
        renderEncoder.popDebugGroup()
    }
}

extension Water {
    @discardableResult
    static func reflectionPass(size: CGSize, needUpdate: Bool = false) -> RenderPass {
        if !needUpdate, let renderPass = Water.reflectionPass {
            return renderPass
        }
        
        let renderPass = RenderPass(name: "Reflection", size: size)
        Water.reflectionPass = renderPass
        
        return renderPass
    }
    
    @discardableResult
    static func refractionPass(size: CGSize, needUpdate: Bool = false) -> RenderPass {
        if !needUpdate, let renderPass = Water.refractionPass {
            return renderPass
        }
        
        let renderPass = RenderPass(name: "Refraction", size: size)
        Water.refractionPass = renderPass
        
        return renderPass
    }
}

