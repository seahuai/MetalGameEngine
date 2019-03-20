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
    
    static var device: MTLDevice!
    static var library: MTLLibrary?
    static var colorPixelFormat: MTLPixelFormat!
    
    final let metalView: MTKView
    final let commandQueue: MTLCommandQueue
    final var depthStencilState: MTLDepthStencilState!
    
    required init(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
                fatalError("GPU not available")
        }
        
        Renderer.device = device
        Renderer.library = device.makeDefaultLibrary()
        Renderer.colorPixelFormat = metalView.colorPixelFormat
        
        self.metalView = metalView
        self.commandQueue = commandQueue
        
        super.init()
        
        self.metalView.delegate = self
        self.metalView.device = device
        
        buildDepthStencilState()
    }
    
    func buildDepthStencilState() {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        depthStencilState = Renderer.device.makeDepthStencilState(descriptor: descriptor)
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
