//
//  LoadObjectRenderer.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/18.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class LoadObjectRenderer: Renderer {
    
    override init(metalView: MTKView) {
        super.init(metalView: metalView)
        
        metalView.delegate = self
        
        metalView.clearColor = MTLClearColor(red: 1, green: 0, blue: 0, alpha: 1)
    }
    
}

extension LoadObjectRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer()
            else { return }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

