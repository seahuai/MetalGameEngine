//
//  RenderPass.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/9.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class RenderPass {
    var descriptor: MTLRenderPassDescriptor!
    var texture: MTLTexture!
    var depthTexture: MTLTexture!
    let name: String
    
    init(name: String, size: CGSize) {
        self.name = name
        
        updateTextures(size: size)
    }
    
    func updateTextures(size: CGSize) {
        initializeTextures(size: size)
        initializeDescriptor()
    }
    
    private func initializeTextures(size: CGSize) {
        texture = Texture.newTexture(pixelFormat: .bgra8Unorm, size: size, label: name)
        depthTexture = Texture.newTexture(pixelFormat: .depth32Float, size: size, label: name)
    }
    
    private func initializeDescriptor() {
        descriptor = MTLRenderPassDescriptor()
        descriptor.setupColorAttachment(index: 0, texture: texture)
        descriptor.setupDepthAttachment(with: depthTexture)
    }
    
}
