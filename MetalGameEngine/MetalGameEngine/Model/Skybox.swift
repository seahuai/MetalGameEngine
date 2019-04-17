//
//  Skybox.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/24.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class Skybox {
    
    var name: String = "Skybox"
    
    var textureName: String?
    
    let mesh: MTKMesh
    
    let pipelineState: MTLRenderPipelineState
    
    let depthStencilState: MTLDepthStencilState
    
    var texture: MTLTexture?
    
    struct Setting {
        // 浑浊程度
        var turbidity: Float = 0.28
        // 太阳高度角
        var sunElevation: Float = 0.6
        // 大气散射
        var upperAtmosphereScattering: Float = 0.1
        // 地面反射
        var groundAlbedo: Float = 4
    }
    
    var setting: Setting? {
        didSet {
            if let setting = self.setting {
                texture = generateSkyboxTexture(setting, dimensions: [256, 256])
            }
        }
    }
    
    init?(textureName: String? = nil) {
        let alloctor = MTKMeshBufferAllocator(device: Renderer.device)
        let cube = MDLMesh(boxWithExtent: [1, 1, 1], segments: [1, 1, 1], inwardNormals: true, geometryType: .triangles, allocator: alloctor)
        
        do {
            mesh = try MTKMesh(mesh: cube, device: Renderer.device)
        } catch {
            return nil
        }
        
        pipelineState = Skybox.buildPipelineState(cube.vertexDescriptor)
        
        depthStencilState = Skybox.buildDepthStencilState()
        
        if let name = textureName {
            texture = Texture.loadCubeTexture(imageName: name)
            self.textureName = name
        }else {
            texture = generateSkyboxTexture(Setting() , dimensions: [256, 256])
        }
        
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder, uniforms: Uniforms) {
        renderEncoder.pushDebugGroup("Skybox")
        renderEncoder.setCullMode(.back)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthStencilState)
        
        renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        
        var uniforms = uniforms;
        // 防止天空盒移动
        uniforms.viewMatrix.columns.3 = [0, 0, 0, 1]
        
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: Int(BufferIndexUniforms.rawValue))
        
        renderEncoder.setFragmentTexture(texture, index: 0)
        
        let submesh = mesh.submeshes[0]
        renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: 0)
        
        renderEncoder.popDebugGroup()
    }
    
    private func generateSkyboxTexture(_ setting: Setting, dimensions: int2) -> MTLTexture? {
        var texture: MTLTexture?
        let skyTexture = MDLSkyCubeTexture(name: "sky",
                                           channelEncoding: .uInt8,
                                           textureDimensions: dimensions,
                                           turbidity: setting.turbidity,
                                           sunElevation: setting.sunElevation,
                                           upperAtmosphereScattering: setting.upperAtmosphereScattering,
                                           groundAlbedo: setting.groundAlbedo)
        do {
            let textureLoader = MTKTextureLoader(device: Renderer.device)
            texture = try textureLoader.newTexture(texture: skyTexture,
                                                   options: nil)
        } catch {
            print(error.localizedDescription)
        }
        return texture
    }
    
}

extension Skybox {
    private class func buildPipelineState(_ vertexDescrptor: MDLVertexDescriptor) -> MTLRenderPipelineState {
        let desciptor = MTLRenderPipelineDescriptor()
        
        desciptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
        desciptor.depthAttachmentPixelFormat = Renderer.depthPixelFormat
        desciptor.vertexFunction = Renderer.library?.makeFunction(name: "vertex_skybox")
        desciptor.fragmentFunction = Renderer.library?.makeFunction(name: "fragment_skybox")
        desciptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescrptor)
        let pipelineState: MTLRenderPipelineState
        
        do {
            pipelineState = try Renderer.device.makeRenderPipelineState(descriptor: desciptor)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        return pipelineState
    }
    
    private class func buildDepthStencilState() -> MTLDepthStencilState {
        let desciptor = MTLDepthStencilDescriptor()
        desciptor.depthCompareFunction = .lessEqual
        desciptor.isDepthWriteEnabled = false
        let depthStencilState = Renderer.device.makeDepthStencilState(descriptor: desciptor)
        return depthStencilState!
    }
}
