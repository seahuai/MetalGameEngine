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
    static var colorPixelFormat: MTLPixelFormat! = .bgra8Unorm
    static var depthPixelFormat: MTLPixelFormat! = .depth32Float
    
    final let metalView: GameView
    final let commandQueue: MTLCommandQueue
    final var depthStencilState: MTLDepthStencilState!
    
    let scene: Scene
    
    required init(metalView: GameView, scene: Scene) {
        guard let commandQueue = Renderer.device.makeCommandQueue() else {
                fatalError("Command queue not available")
        }
        
        metalView.colorPixelFormat = Renderer.colorPixelFormat
        metalView.depthStencilPixelFormat = Renderer.depthPixelFormat
        
        self.metalView = metalView
        self.commandQueue = commandQueue
        self.scene = scene
        
        super.init()
        
        self.metalView.delegate = self
        self.metalView.device = Renderer.device
        
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
        scene.sceneSizeWillChange(size)
        mtkView(drawableSizeWillChange: size)
    }
    
    func draw(in view: MTKView) {
        // 没有光照和视点不进行渲染
        if type(of: self) != RayTracingTestRenderer.self {
            guard !scene.lights.isEmpty, scene.currentCamera != nil else { return }
        }
        
        guard let drawable = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer()
            else { return }
        
        updateNode()
        
        draw(with: descriptor, commandBuffer: commandBuffer)
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    private func updateNode() {
        guard let node = metalView.inputController?.node else { return }
        let holdPosition = node.position
        let holdRotation = node.rotation
        let deltaTime = 1.0 / Float(metalView.preferredFramesPerSecond)
        
        metalView.physicsController?.dynamicBody = node

        // update inputController
        metalView.inputController?.update(deltaTime)
        
        // check collied
        if let physicsController = metalView.physicsController, physicsController.checkCollisions() {
            node.position = holdPosition
            node.rotation = holdRotation
        }
    }
}
