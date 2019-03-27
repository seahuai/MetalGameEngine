//
//  LoadObjectRenderer.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/18.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class PBRRenderer: Renderer {
    
    private var props: [Prop] = []
    
    required init(metalView: MTKView, scene: Scene) {
        super.init(metalView: metalView, scene: scene)
    }
    
    override func mtkView(drawableSizeWillChange size: CGSize) {
        props = scene.props(type: .PBR)
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
