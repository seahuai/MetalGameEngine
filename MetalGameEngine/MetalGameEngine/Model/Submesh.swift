//
//  Submesh.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/19.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class Submesh {
    
    let texture: Texture
    let material: Material
    let vertexDescriptor: MDLVertexDescriptor
    
    var renderPipelineState: MTLRenderPipelineState?
    
    let mtkSubmesh: MTKSubmesh
    
    init(mtkSubmesh: MTKSubmesh, mdlsubmesh: MDLSubmesh, vertexDescriptor: MDLVertexDescriptor) {
        self.mtkSubmesh = mtkSubmesh
        
        self.texture = Texture(material: mdlsubmesh.material)
        self.material = Material(material: mdlsubmesh.material)
        self.vertexDescriptor = vertexDescriptor
    }
    
    func setNeedsToRender(vertexFunctionName: String, fragmentFunctionName: String) {
        let constantValues = makeFunctionConstant()
        
        let vertexFunction = Renderer.library?.makeFunction(name: vertexFunctionName)
        let fragmentFunction: MTLFunction?
        do {
            fragmentFunction = try Renderer.library?.makeFunction(name: fragmentFunctionName, constantValues: constantValues)
        } catch {
            fatalError("get fragmentFunction error, reason:\(error.localizedDescription)")
        }
        
        makeRenderPipeline(vertexFunction: vertexFunction, fragmentFunction: fragmentFunction)
    }
    
    private func makeFunctionConstant() -> MTLFunctionConstantValues {
        let functionConstants = MTLFunctionConstantValues()
        var property = self.texture.color != nil
        functionConstants.setConstantValue(&property, type: .bool, index: 0)
        property = self.texture.normal != nil
        functionConstants.setConstantValue(&property, type: .bool, index: 1)
        property = self.texture.roughness != nil
        functionConstants.setConstantValue(&property, type: .bool, index: 2)
//        property = false
//        functionConstants.setConstantValue(&property, type: .bool, index: 3)
//        functionConstants.setConstantValue(&property, type: .bool, index: 4)
        
        return functionConstants
    }
    
    private func makeRenderPipeline(vertexFunction: MTLFunction?,
                                    fragmentFunction: MTLFunction?)  {
        
        let descripator = MTLRenderPipelineDescriptor()
        
        descripator.vertexFunction = vertexFunction
        descripator.fragmentFunction = fragmentFunction
        
        descripator.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
        descripator.depthAttachmentPixelFormat = .depth32Float
        descripator.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
        
        do {
            renderPipelineState = try Renderer.device.makeRenderPipelineState(descriptor: descripator)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
