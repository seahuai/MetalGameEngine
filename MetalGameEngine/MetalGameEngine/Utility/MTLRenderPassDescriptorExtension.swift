//
//  MTLRenderPassDescriptorExtension.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/23.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Metal

extension MTLRenderPassDescriptor {
    func setupDepthAttachment(with texture: MTLTexture) {
        depthAttachment.texture = texture
        depthAttachment.loadAction = .clear
        depthAttachment.storeAction = .store
        depthAttachment.clearDepth = 1
    }
    
    func setupColorAttachment(index: Int, texture: MTLTexture) {
        let attachment = self.colorAttachments[index]
        attachment?.texture = texture
        attachment?.loadAction = .clear
        attachment?.storeAction = .store
    }
}
