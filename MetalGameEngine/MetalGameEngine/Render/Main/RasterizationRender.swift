//
//  RasterizationRender.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/14.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class RasterizationRenderer: Renderer {
    
    // 用于渲染的对象
    private var props: [Prop] = []
    
    // 用于渲染阴影纹理的对象
    private var shadowProps: [Prop] = []
    
    // Unifroms
    private var uniforms = Uniforms()
    
    // Lights Buffer
    private var lightsBuffer: MTLBuffer?
    
    // 渲染阴影相关
    private var shadowRenderPass: RenderPass?
    private var firstDirectionalLight: Light?
    
    
    required init(metalView: GameView, scene: Scene) {
        super.init(metalView: metalView, scene: scene)
        
        scene.delegate = self
        
        if metalView.drawableSize.width != .zero && metalView.drawableSize.height != 0 {
            shadowRenderPass = RenderPass(name: "Shadow", size: metalView.drawableSize, isDepth: true)
        }
        
    }
    
    override func mtkView(drawableSizeWillChange size: CGSize) {
        if shadowRenderPass == nil {
            shadowRenderPass = RenderPass(name: "Shadow", size: size, isDepth: true)
        }
        shadowRenderPass?.updateTextures(size: size)
    }
    
    override func draw(with mainPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {
        
        // 渲染阴影纹理
        renderShadowPass(commandBuffer)
        
        // 渲染主要内容
        renderMain(mainPassDescriptor, commandBuffer: commandBuffer)
    }
}

private extension RasterizationRenderer {
    // MARK: - Render Shadow
    func renderShadowPass(_ commandBuffer: MTLCommandBuffer) {
        guard let shadowRenderPass = shadowRenderPass else { return }
        // 没有直射光就不渲染阴影
        guard let light = self.firstDirectionalLight,
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: shadowRenderPass.descriptor) else {
            return
        }
        
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
    
    // MARK: - Render Main
    func renderMain(_ mainPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {
        
        // 需要计算的优先处理
        
        // 计算地形相关数据
        let terrains = scene.terrains
        terrains.forEach { (terrain) in
            terrain.compute(mainPassDescriptor: mainPassDescriptor, commandBuffer: commandBuffer, uniforms: scene.uniforms, cameraPosition: scene.fragmentUniforms.cameraPosition)
        }
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: mainPassDescriptor) else {
            return
        }
        
        renderEncoder.pushDebugGroup("Main")
        
        renderEncoder.setDepthStencilState(self.depthStencilState)
        
        // 重置 uniforms 的 viewMatrix 和 projectionMatrix
        uniforms.viewMatrix = scene.uniforms.viewMatrix
        uniforms.projectionMatrix = scene.uniforms.projectionMatrix
        
        renderEncoder.setFragmentTexture(shadowRenderPass?.depthTexture, index: Int(ShadowTexture.rawValue))
        renderEncoder.setFragmentBuffer(lightsBuffer, offset: 0, index: Int(BufferIndexLights.rawValue))
        
        for prop in props {
            prop.render(renderEncoder: renderEncoder, uniforms: uniforms, fragmentUniforms: scene.fragmentUniforms)
        }
        
        // 渲染天空盒
        scene.skybox?.render(renderEncoder: renderEncoder, uniforms: scene.uniforms)
        
        // 渲染地形
        terrains.forEach { (terrain) in
            terrain.render(renderEncoder)
        }
        
        renderEncoder.endEncoding()
        
        renderEncoder.popDebugGroup()
    }
}


extension RasterizationRenderer: SceneDelegate {
    func scene(_ scene: Scene, didChangeModels models: [Model]) {
        props = scene.props(type: .Phong)
        shadowProps = scene.props(type: .Depth)
    }
    
    func scene(_ scnee: Scene, didChangeLights lights: [Light]) {
        guard !lights.isEmpty else {
            lightsBuffer = nil
            return
        }
        
        firstDirectionalLight = lights.first{ $0.type == Sunlight }
        lightsBuffer = Renderer.device.makeBuffer(bytes: lights, length: MemoryLayout<Light>.stride * lights.count, options: [])
    }
}
