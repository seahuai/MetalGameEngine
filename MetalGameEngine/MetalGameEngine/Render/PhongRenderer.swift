//
//  PhongRenderer.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/24.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class PhongRenderer: Renderer {
    
    private var props: [Prop] = []
     
    required init(metalView: MTKView, scene: Scene) {
        super.init(metalView: metalView, scene: scene)
    }
    
    override func mtkView(drawableSizeWillChange size: CGSize) {
        scene.sceneSizeWillChange(size)
        
        props = scene.props(type: .Phong)
        
        Water.reflectionPass(size: size, needUpdate: true)
        Water.refractionPass(size: size, needUpdate: true)
    }
    
    override func draw(with mainPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {
        
        renderWaterTextures(with: commandBuffer)
        
        var uniforms = scene.uniforms
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: mainPassDescriptor) else {
            return
        }

        renderEncoder.setDepthStencilState(self.depthStencilState)

        renderEncoder.setFragmentBytes(scene.lights, length: MemoryLayout<Light>.stride * scene.lights.count, index: Int(BufferIndexLights.rawValue))

        for prop in props {
            prop.render(renderEncoder: renderEncoder, uniforms: uniforms, fragmentUniforms: scene.fragmentUniforms)
        }
        
        scene.skybox?.render(renderEncoder: renderEncoder, uniforms: scene.uniforms)
        
        renderWater(in: renderEncoder)
        
        Debug.debugLight(in: scene, with: renderEncoder)

        renderEncoder.endEncoding()
    }
}

extension PhongRenderer {
    
    func renderWaterTextures(with commandBuffer: MTLCommandBuffer) {
        
        var uniforms = scene.uniforms
        let drawableSize = self.metalView.drawableSize
        // refletion
        let reflectionPass = Water.reflectionPass(size: drawableSize)
        guard let reflectionEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: reflectionPass.descriptor) else { return }
        reflectionEncoder.setFragmentBytes(scene.lights, length: MemoryLayout<Light>.stride * scene.lights.count, index: Int(BufferIndexLights.rawValue))
        let reflectionCamera = scene.currentCamera.copy;
        reflectionCamera.position.y *= -1;
        reflectionCamera.rotation = [0, 0, 0];
        reflectionCamera.rotation.x = -scene.currentCamera.rotation.x

        uniforms.clipPlane = [0, 1, 0, 0.1]
        uniforms.viewMatrix = reflectionCamera.viewMatrix
        renderProps(in: reflectionEncoder, uniforms: uniforms, fragmentUniforms: scene.fragmentUniforms)
        scene.skybox?.render(renderEncoder: reflectionEncoder, uniforms: uniforms)
        reflectionEncoder.endEncoding()
    }
    
    func renderWater(in renderEncoder: MTLRenderCommandEncoder) {
        scene.renderWaters(renderEncoder: renderEncoder,
                           reflectionTexture: Water.reflectionPass?.texture,
                           refractionTexture: nil)
    }
    
    private func renderProps(in renderEncoder: MTLRenderCommandEncoder, uniforms: Uniforms, fragmentUniforms: FragmentUniforms) {
        for prop in props {
            prop.render(renderEncoder: renderEncoder, uniforms: uniforms, fragmentUniforms: fragmentUniforms)
        }
    }
    
}
