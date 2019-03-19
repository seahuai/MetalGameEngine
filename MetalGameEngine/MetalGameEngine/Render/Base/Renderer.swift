//
//  Renderer.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/18.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

// MARK: Base Class

class Renderer: NSObject {
    
    final let metalView: MTKView
    final let device: MTLDevice
    final let commandQueue: MTLCommandQueue
    
    required init(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
                fatalError("GPU not available")
        }
        
        self.metalView = metalView
        
        self.device = device
        
        self.commandQueue = commandQueue
        
        metalView.device = device
        
        super.init()
    }
    
    // need override
    func draw(with mainPassDescriptor: MTLRenderPassDescriptor,
              commandBuffer: MTLCommandBuffer) {}
    
    func mtkView(drawableSizeWillChange size: CGSize) {}
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        mtkView(drawableSizeWillChange: size)
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer()
            else { return }
        
        draw(with: descriptor, commandBuffer: commandBuffer)
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
