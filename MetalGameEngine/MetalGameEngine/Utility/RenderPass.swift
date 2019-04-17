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
    var texture: MTLTexture?
    var depthTexture: MTLTexture!
    let isDepth: Bool
    let name: String
    
    init(name: String, size: CGSize, isDepth: Bool = false) {
        self.name = name
        self.isDepth = isDepth
        updateTextures(size: size)
    }
    
    func updateTextures(size: CGSize) {
        initializeTextures(size: size)
        initializeDescriptor()
    }
    
    private func initializeTextures(size: CGSize) {
        if !isDepth {
            texture = Texture.newTexture(pixelFormat: .bgra8Unorm, size: size, label: name)
        }
        depthTexture = Texture.newTexture(pixelFormat: Renderer.depthPixelFormat, size: size, label: name)
    }
    
    private func initializeDescriptor() {
        descriptor = MTLRenderPassDescriptor()
        if let texture = texture {
            descriptor.setupColorAttachment(index: 0, texture: texture)
        }
        descriptor.setupDepthAttachment(with: depthTexture)
    }
    
}
