//
//  DebugLight.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/3.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

// MARK: Debug Light
class Debug {
    
    static var isDebugLightEnable = false
    
    private static var lightPipelineState: MTLRenderPipelineState?
    
    static func debugLight(in scene: Scene, with renderEncoder: MTLRenderCommandEncoder, depthStencilState: MTLDepthStencilState? = nil) {
        
        guard isDebugLightEnable else { return }
        
        guard scene.lights.count != 0 else { return }
        
        if let pipelineState = Debug.lightPipelineState {
            
            renderEncoder.pushDebugGroup("Debug Light")
            
            if let depthStencilState = depthStencilState {
                renderEncoder.setDepthStencilState(depthStencilState)
            }
            
            renderEncoder.setRenderPipelineState(pipelineState)
            drawLights(in: scene, renderEncoder: renderEncoder)
            
            renderEncoder.popDebugGroup()
            
        } else {
            let vertexFunction = Renderer.library?.makeFunction(name: "debugVertex_light")
            let fragmentFunction = Renderer.library?.makeFunction(name: "debugFragment_light")
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
            pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
            
            do {
                Debug.lightPipelineState = try Renderer.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch let error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private static func drawLights(in scene: Scene, renderEncoder: MTLRenderCommandEncoder) {
        
        for light in scene.lights {
            
            var vertices: [float3] = []
            var primitiveType: MTLPrimitiveType = .point
            var color = light.color
            
            switch light.type {
                
            case Pointlight:
                
                vertices.append(light.position)
                primitiveType = .point

            case Spotlight:
                
                vertices.append(light.position)
                vertices.append([light.position.x + light.coneDirection.x,
                                 light.position.y + light.coneDirection.y,
                                 light.position.z + light.coneDirection.z ])
                primitiveType = .line
                
                
            case Sunlight:
                
                let direction = light.position
                for i in -5..<5 {
                    let value = Float(i) * 0.4
                    vertices.append(float3(value, 0, value))
                    vertices.append([direction.x + value,
                                     direction.y,
                                     direction.z + value])
                }
                primitiveType = .line
                
            default:
                continue
            }
            
            let vertexBuffer = Renderer.device.makeBuffer(bytes: vertices, length: MemoryLayout<float3>.stride * vertices.count, options: [])
            var uniforms = scene.uniforms
            uniforms.modelMatrix = float4x4.identity()
            
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
            renderEncoder.setFragmentBytes(&color, length: MemoryLayout<float3>.stride, index: 1)
            
            renderEncoder.drawPrimitives(type: primitiveType, vertexStart: 0, vertexCount: vertices.count)
            
        }
    }
    
    
    
}
