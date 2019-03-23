//
//  Prop.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/20.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

protocol Renderable {
    var identifier: String { get }
    var name: String { get }
    func render(renderEncoder: MTLRenderCommandEncoder, uniforms: Uniforms)
}

// 负责Model的渲染
class Prop {
    
    let model: Model
    
     init(model: Model) {
        self.model = model
        self.model.setNeedsToRender()
    }
}

extension Prop: Renderable {
    
    var identifier: String {
        return model.identifier
    }
    
    var name: String {
        return model.name
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, uniforms: Uniforms) {
        var _uniforms = uniforms
        _uniforms.modelMatrix = model.worldTransform
        _uniforms.normalMatrix = float3x3(normalFrom4x4: model.modelMatrix)
        
        renderEncoder.setVertexBytes(&_uniforms, length: MemoryLayout<Uniforms>.stride, index: Int(BufferIndexUniforms.rawValue))
        
        // 将顶点、切空间等数据送给着色器
        for (index, vertexBuffer) in model.mesh.vertexBuffers.enumerated() {
            renderEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: index)
        }
        
        for submesh in model.submeshes {
            renderEncoder.setRenderPipelineState(submesh.renderPipelineState!)
            
            // 纹理
            renderEncoder.setFragmentTexture(submesh.texture.color, index: Int(BaseColorTexture.rawValue))
            renderEncoder.setFragmentTexture(submesh.texture.normal, index: Int(NormalTexture.rawValue))
            renderEncoder.setFragmentTexture(submesh.texture.roughness, index: Int(RoughnessTexture.rawValue))
            renderEncoder.setFragmentTexture(submesh.texture.metallic, index: Int(MetallicTexture.rawValue))
            renderEncoder.setFragmentTexture(submesh.texture.ambientOcclusion, index: Int(AOTexture.rawValue))
            
            var material = submesh.material
            renderEncoder.setFragmentBytes(&material, length: MemoryLayout<Material>.stride, index: Int(BufferIndexMaterials.rawValue))
            
            // 绘制
            let mtkSubmesh = submesh.mtkSubmesh
            renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                indexCount: mtkSubmesh.indexCount,
                                                indexType: mtkSubmesh.indexType,
                                                indexBuffer: mtkSubmesh.indexBuffer.buffer,
                                                indexBufferOffset: mtkSubmesh.indexBuffer.offset)
            
        }
        
    }
}
