//
//  ShadowRenderer.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/23.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit


class ShadowRenderer: Renderer {
    
    var time: Float = 0
    
    var light: Light!
    
    var props: [Prop] = []
    
    var uniforms = Uniforms()
    
    var depthProps: [Prop] = []
    var shadowTexture: MTLTexture!
    var shadowPassDescriptor = MTLRenderPassDescriptor()
    var shadowRenderPipelineState: MTLRenderPipelineState!
    
    convenience init(metalView: GameView, scene: Scene, light: Light) {
        self.init(metalView: metalView, scene: scene)
        self.light = light
    }
    
    required init(metalView: GameView, scene: Scene) {
        super.init(metalView: metalView, scene: scene)
    }
    
    func buildDepthTexture(with size: CGSize) {
        shadowTexture = Texture.newTexture(pixelFormat: .depth32Float, size: size, label: "shadow")
        shadowPassDescriptor.setupDepthAttachment(with: shadowTexture)
    }
    
    func buildProps() {
        props = scene.props(type: .Phong)
        depthProps = scene.props(type: .Depth)
    }
    
    
    // MARK: Shadow
    func renderShadowPass(_ renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.pushDebugGroup("shadow")
        
        time += 0.01
        
        light.position.z = cos(time) * 10
        
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
        
        for prop in depthProps {
            prop.render(renderEncoder: renderEncoder, uniforms: uniforms, fragmentUniforms: scene.fragmentUniforms)
        }
        
        renderEncoder.endEncoding()
        
        renderEncoder.popDebugGroup()
    }
    
    // MARK: - Main
    func renderMainPass(_ renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.pushDebugGroup("main")
        
        renderEncoder.setDepthStencilState(self.depthStencilState)
        
        uniforms.viewMatrix = scene.uniforms.viewMatrix
        uniforms.projectionMatrix = scene.uniforms.projectionMatrix
        
        renderEncoder.setFragmentTexture(shadowTexture, index: Int(ShadowTexture.rawValue))
        
        renderEncoder.setFragmentBytes(scene.lights, length: MemoryLayout<Light>.stride * scene.lights.count, index: Int(BufferIndexLights.rawValue))
        
        for prop in props {
            prop.render(renderEncoder: renderEncoder, uniforms: uniforms, fragmentUniforms: scene.fragmentUniforms)
        }
        
        scene.skybox?.render(renderEncoder: renderEncoder, uniforms: uniforms)
        
        renderEncoder.endEncoding()
        
        renderEncoder.popDebugGroup()
    }
        
    override func mtkView(drawableSizeWillChange size: CGSize) {
        buildDepthTexture(with: size)
        buildProps()
    }
    
    override func draw(with mainPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {
        
        guard let shadowRenderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: shadowPassDescriptor) else {
            return
        }
    
        renderShadowPass(shadowRenderEncoder)
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: mainPassDescriptor) else {
            return
        }
        
        renderMainPass(renderEncoder)
    }
    
}
