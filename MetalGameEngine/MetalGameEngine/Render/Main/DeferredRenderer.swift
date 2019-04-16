//
//  DeferredRenderer.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/27.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class DeferredRenderer: Renderer {
    
    // Shadow
    var light: Light!
    var shadowRendererPass: MTLRenderPassDescriptor!
    var shadowProps: [Prop] = []
    var shadowTexture: MTLTexture!
    
    // Gbuffer
    var gBufferRenderePass: MTLRenderPassDescriptor!
    var gbufferProps: [Prop] = []
    var depthTexture: MTLTexture!
    var baseColorTexture: MTLTexture!
    var normalTexture: MTLTexture!
    var positionTexture: MTLTexture!
    
    // Composition
    var lightsBuffer: MTLBuffer!
    var quadVertexBuffer: MTLBuffer!
    var quadTextureCoodBuffer: MTLBuffer!
    var compositionPipelineState: MTLRenderPipelineState!
    
    var uniforms: Uniforms!
    
    required init(metalView: MTKView, scene: Scene) {
        super.init(metalView: metalView, scene: scene)
        
        buildProps()
        buildLights()
        
        uniforms = scene.uniforms
        
        buildCompositionPipeline()
    }
    
    func buildProps() {
        shadowProps = self.scene.props(type: .Depth)
        gbufferProps = self.scene.props(type: .Gbuffer)
    }
    
    func buildLights() {
        light = scene.lights.first{ $0.type == Sunlight }
        lightsBuffer = Renderer.device.makeBuffer(bytes: scene.lights, length: MemoryLayout<Light>.stride * scene.lights.count, options: [])
    }
    
    override func mtkView(drawableSizeWillChange size: CGSize) {
        scene.sceneSizeWillChange(size)
        
        buildProps()
        
        buildShadowRenderPass(size: size)
        
        buildGbufferRenderPass(size: size)
    }

    override func draw(with mainPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {
        guard let shadowRenderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: shadowRendererPass) else {
            return
        }
        renderShadow(shadowRenderEncoder, light: self.light)
        
        guard let gBufferRenderer = commandBuffer.makeRenderCommandEncoder(descriptor: gBufferRenderePass) else {
            return
        }
        renderGbuffer(gBufferRenderer)
        
        guard let mainRenderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: mainPassDescriptor) else {
            return
        }
        
        renderMain(mainRenderEncoder)
        
        mainRenderEncoder.endEncoding()
    }
}

// MARK: - Shadow
extension DeferredRenderer {
    func buildShadowRenderPass(size: CGSize) {
        shadowTexture = Texture.newTexture(pixelFormat: .depth32Float, size: size, label: "Shadow")
        shadowRendererPass = MTLRenderPassDescriptor()
        shadowRendererPass.setupDepthAttachment(with: shadowTexture)
    }
    
    func renderShadow(_ renderEncoder: MTLRenderCommandEncoder, light: Light) {
        renderEncoder.pushDebugGroup("shadow")
        renderEncoder.label = "Shadow RenderEncoder"
        
        renderEncoder.setCullMode(.none)
        renderEncoder.setDepthStencilState(self.depthStencilState)
        
        renderEncoder.setDepthBias(0.01, slopeScale: 1.0, clamp: 0.01)
        
        uniforms.projectionMatrix = float4x4(orthoLeft: -8, right: 8,
                                             bottom: -8, top: 8,
                                             near: 0.1, far: 16)
        let position: float3 = [-light.position.x,
                                -light.position.y,
                                -light.position.z]
        let center: float3 = [0, 0, 0]
        let lookAt = float4x4(eye: position, center: center, up: [0,1,0])
        uniforms.viewMatrix = float4x4(translation: [0, 0, 7]) * lookAt
        uniforms.shadowMatrix = uniforms.projectionMatrix * uniforms.viewMatrix
        
        for prop in shadowProps {
            prop.render(renderEncoder: renderEncoder, uniforms: uniforms, fragmentUniforms: scene.fragmentUniforms)
        }
        
        renderEncoder.endEncoding()
        
        renderEncoder.popDebugGroup()
    }
}

// MARK: - Gbuffer
extension DeferredRenderer {
    func buildGbufferRenderPass(size: CGSize) {
        baseColorTexture = Texture.newTexture(pixelFormat: .bgra8Unorm, size: size, label: "Color")
        normalTexture = Texture.newTexture(pixelFormat: .rgba16Float, size: size, label: "Normal")
        positionTexture = Texture.newTexture(pixelFormat: .rgba16Float, size: size, label: "Position")
        depthTexture = Texture.newTexture(pixelFormat: .depth32Float, size: size, label: "Depth")
        
        gBufferRenderePass = MTLRenderPassDescriptor()
        
        gBufferRenderePass.setupColorAttachment(index: 0, texture: baseColorTexture)
        gBufferRenderePass.setupColorAttachment(index: 1, texture: normalTexture)
        gBufferRenderePass.setupColorAttachment(index: 2, texture: positionTexture)
        gBufferRenderePass.setupDepthAttachment(with: depthTexture)
    }
    
    func renderGbuffer(_ renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.pushDebugGroup("Gbuffer")
        renderEncoder.label = "Gbuffer RenderEncoder"
        
        uniforms.viewMatrix = scene.uniforms.viewMatrix
        uniforms.projectionMatrix = scene.uniforms.projectionMatrix
        
        renderEncoder.setDepthStencilState(self.depthStencilState)
        
        renderEncoder.setFragmentTexture(shadowTexture, index: Int(ShadowTexture.rawValue))
        
        for prop in gbufferProps {
            prop.render(renderEncoder: renderEncoder, uniforms: uniforms, fragmentUniforms: scene.fragmentUniforms)
        }
        
        renderEncoder.endEncoding()
        
        renderEncoder.popDebugGroup()
    }
}

// MARK: - Composition
extension DeferredRenderer {
    func buildCompostionBuffer() {
        let quadVertices: [Float] = [ -1.0,  1.0, 1.0, -1.0,
                                      -1.0, -1.0, -1.0,  1.0,
                                       1.0,  1.0,  1.0, -1.0]
        
        let quadTexCoords: [Float] = [ 0.0, 0.0, 1.0, 1.0,
                                       0.0, 1.0, 0.0, 0.0,
                                       1.0, 0.0, 1.0, 1.0]
        
        quadVertexBuffer = Renderer.device.makeBuffer(bytes: quadVertices, length: MemoryLayout<Float>.size * quadVertices.count, options: [])
        quadTextureCoodBuffer = Renderer.device.makeBuffer(bytes: quadTexCoords, length: MemoryLayout<Float>.size * quadTexCoords.count, options: [])
    }
    
    func buildCompositionPipeline() {
        buildCompostionBuffer()
        
        let desciptor = MTLRenderPipelineDescriptor()
        desciptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
        desciptor.depthAttachmentPixelFormat = .depth32Float
        desciptor.vertexFunction = Renderer.library?.makeFunction(name: "vertex_composition")
        desciptor.fragmentFunction = Renderer.library?.makeFunction(name: "fragment_composition")
        
        do {
            compositionPipelineState = try Renderer.device.makeRenderPipelineState(descriptor: desciptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func renderMain(_ renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.pushDebugGroup("Composition")
        renderEncoder.label = "Composition RenderEncoder"
        
        scene.skybox?.render(renderEncoder: renderEncoder, uniforms: scene.uniforms)
        
        renderEncoder.setRenderPipelineState(compositionPipelineState)
        renderEncoder.setDepthStencilState(self.depthStencilState)
        
        renderEncoder.setVertexBuffer(quadVertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(quadTextureCoodBuffer, offset: 0, index: 1)
        
        var fragmentUniforms = scene.fragmentUniforms
        renderEncoder.setFragmentBytes(&fragmentUniforms, length: MemoryLayout<FragmentUniforms>.stride, index: 0)
        
        renderEncoder.setFragmentBuffer(lightsBuffer, offset: 0, index: 1)
        
        renderEncoder.setFragmentTexture(baseColorTexture, index: 0)
        renderEncoder.setFragmentTexture(normalTexture, index: 1)
        renderEncoder.setFragmentTexture(positionTexture, index: 2)
        
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 12)
        
        renderEncoder.popDebugGroup()
    }
}
