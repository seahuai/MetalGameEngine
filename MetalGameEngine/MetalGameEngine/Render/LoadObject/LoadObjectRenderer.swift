//
//  LoadObjectRenderer.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/18.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class LoadObjectRenderer: Renderer {
    
    required init(metalView: MTKView) {
        super.init(metalView: metalView)
    }
    
    override func mtkView(drawableSizeWillChange size: CGSize) {
        
    }
    
    override func draw(with mainPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {
        
    }
    
}
