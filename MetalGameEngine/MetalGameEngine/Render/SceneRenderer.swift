//
//  LoadObjectRenderer.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/18.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class SceneRenderer: Renderer {
    
    var scene: Scene!
    
    convenience init(metalView: MTKView, scene: Scene) {
        self.init(metalView: metalView)
        self.scene = scene
    }
    
    required init(metalView: MTKView) {
        super.init(metalView: metalView)
    }
    
    override func mtkView(drawableSizeWillChange size: CGSize) {
        scene.sceneSizeWillChange(size)
    }
    
    override func draw(with mainPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: mainPassDescriptor) else {
            return
        }
        
        renderEncoder.setDepthStencilState(self.depthStencilState)
        scene.render(renderEncoder: renderEncoder)
        
        renderEncoder.endEncoding()
    }
    
}
