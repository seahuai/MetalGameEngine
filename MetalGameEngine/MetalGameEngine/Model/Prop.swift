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
    func render(renderEncoder: MTLRenderCommandEncoder, uniforms: Uniforms, fragmentUniforms: FragmentUniforms)
}

enum RendererType {
    case PBR
    case Phong
    case Gbuffer
    case Depth
    case custom(v: String, f: String)
}

private class RenderableSubmesh {
    let submesh: Submesh
    var renderPipelineState: MTLRenderPipelineState!
    
    init(_ submesh: Submesh, type: RendererType) {
        self.submesh = submesh
        
        makeRendererPipeline(type)
    }
    
    func makeRendererPipeline(_ type: RendererType) {
        
        var descripator = MTLRenderPipelineDescriptor()
        
        let vFunction: MTLFunction?
        let fFunction: MTLFunction?
        
        func makeFunction(name: String, constantValues: MTLFunctionConstantValues? = nil) -> MTLFunction? {
            let function: MTLFunction?
            
            if let constantValues = constantValues {
                do {
                    function = try Renderer.library?.makeFunction(name: name, constantValues: constantValues)
                } catch {
                    fatalError(error.localizedDescription)
                }
            }else {
                function = Renderer.library?.makeFunction(name: name)
            }
            
            return function
        }
        
        switch type {
        case .PBR:
            vFunction = makeFunction(name: "vertex_main")
            fFunction = makeFunction(name: "fragment_PBR", constantValues: makeFunctionConstant())
            descripator.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
        case .Phong:
            vFunction = makeFunction(name: "vertex_main")
            fFunction = makeFunction(name: "fragment_phong", constantValues: makeFunctionConstant())
            descripator.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
        case .Depth:
            vFunction = makeFunction(name: "vertex_depth")
            fFunction = nil
            descripator.colorAttachments[0].pixelFormat = .invalid
        case .Gbuffer:
            fatalError("not availabel")
        default:
            fatalError("not availabel")
        }
        
        descripator.vertexFunction = vFunction
        descripator.fragmentFunction = fFunction
        descripator.depthAttachmentPixelFormat = .depth32Float
        descripator.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(submesh.vertexDescriptor)
        
        do {
            renderPipelineState = try Renderer.device.makeRenderPipelineState(descriptor: descripator)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func makeFunctionConstant() -> MTLFunctionConstantValues {
        let functionConstants = MTLFunctionConstantValues()
        var property = self.submesh.texture.color != nil
        functionConstants.setConstantValue(&property, type: .bool, index: 0)
        property = self.submesh.texture.normal != nil
        functionConstants.setConstantValue(&property, type: .bool, index: 1)
        property = self.submesh.texture.roughness != nil
        functionConstants.setConstantValue(&property, type: .bool, index: 2)
        property = self.submesh.texture.metallic != nil
        functionConstants.setConstantValue(&property, type: .bool, index: 3)
        property = self.submesh.texture.ambientOcclusion != nil
        functionConstants.setConstantValue(&property, type: .bool, index: 4)
        
        return functionConstants
    }
}

class Prop {
    
    private let renderableSubmeshes: [RenderableSubmesh]
    
    let model: Model
    
    init(model: Model, type: RendererType) {
        self.model = model
        renderableSubmeshes = model.submeshes.map{ RenderableSubmesh($0, type: type) }
    }
}

extension Prop {
    
    var identifier: String {
        return model.identifier
    }
    
    var name: String {
        return model.name
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder,
                pipelineState: MTLRenderPipelineState? = nil,
                uniforms: Uniforms,
                fragmentUniforms: FragmentUniforms) {
        
        renderEncoder.pushDebugGroup(self.name)
        
        var _uniforms = uniforms
        _uniforms.modelMatrix = model.worldTransform
        _uniforms.normalMatrix = float3x3(normalFrom4x4: model.modelMatrix)
        
        var _fragmentUniforms = fragmentUniforms
        _fragmentUniforms.tiling = uint(model.tiling)
        
        renderEncoder.setVertexBytes(&_uniforms, length: MemoryLayout<Uniforms>.stride, index: Int(BufferIndexUniforms.rawValue))
        renderEncoder.setFragmentBytes(&_fragmentUniforms, length: MemoryLayout<FragmentUniforms>.stride, index: Int(BufferIndexFragmentUniforms.rawValue))
        
        // 将顶点、切空间等数据送给着色器
        for (index, vertexBuffer) in model.mesh.vertexBuffers.enumerated() {
            renderEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: index)
        }
        
        for renderableSubmesh in self.renderableSubmeshes {
            let submesh = renderableSubmesh.submesh
            
            if (pipelineState == nil) {
                renderEncoder.setRenderPipelineState(renderableSubmesh.renderPipelineState)
            }
            
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
        
        renderEncoder.popDebugGroup()
        
    }
}
