//
//  PhongRenderer.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/24.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class PhongRenderer: Renderer {
    var scene: Scene!
    
    private var props: [Prop] = []
    
    convenience init(metalView: MTKView, scene: Scene) {
        self.init(metalView: metalView)
        self.scene = scene
    }
    
    required init(metalView: MTKView) {
        super.init(metalView: metalView)
    }
    
    override func mtkView(drawableSizeWillChange size: CGSize) {
        scene.sceneSizeWillChange(size)
        
        props = scene.props(type: .Phong)
    }
    
    override func draw(with mainPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: mainPassDescriptor) else {
            return
        }
        
        renderEncoder.setDepthStencilState(self.depthStencilState)
        
        renderEncoder.setFragmentBytes(scene.lights, length: MemoryLayout<Light>.stride * scene.lights.count, index: Int(BufferIndexLights.rawValue))
        
        for prop in props {
            prop.render(renderEncoder: renderEncoder, uniforms: scene.uniforms, fragmentUniforms: scene.fragmentUniforms)
        }
        
        renderEncoder.endEncoding()
    }
}
