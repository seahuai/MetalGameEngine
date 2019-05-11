//
//  TerrainRenderer.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/29.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class TerrainRenderer: Renderer {
    
    required init(metalView: GameView, scene: Scene) {
        super.init(metalView: metalView, scene: scene)
    }
    
    override func draw(with mainPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {
        
        // 计算地形相关数据
        let terrains = scene.terrains
        terrains.forEach { (terrain) in
            terrain.compute(mainPassDescriptor: mainPassDescriptor, commandBuffer: commandBuffer, uniforms: scene.uniforms, cameraPosition: scene.fragmentUniforms.cameraPosition)
        }
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: mainPassDescriptor) else {
            return
        }
        
        // 渲染地形
        terrains.forEach { (terrain) in
            terrain.render(renderEncoder)
        }
        
        renderEncoder.endEncoding()
        
    }
}
