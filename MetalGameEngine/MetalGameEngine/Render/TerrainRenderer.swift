//
//  TerrainRenderer.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/29.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class TerrainRenderer: Renderer {
    
    required init(metalView: MTKView, scene: Scene) {
        super.init(metalView: metalView, scene: scene)
    }
    
    override func draw(with mainPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {
        
        self.scene.terrain?.render(mainPassDescriptor: mainPassDescriptor,
                                   commandBuffer: commandBuffer,
                                   uniforms: scene.uniforms,
                                   cameraPosition: scene.currentCamera.position)
        
    }
}