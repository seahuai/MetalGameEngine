//
//  Texture.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/20.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

struct Texture {
    let color: MTLTexture?
    let normal: MTLTexture?
    let roughness: MTLTexture?
    let metallic: MTLTexture?
    let ambientOcclusion: MTLTexture?
}

extension Texture {
    
    private static func property(with material: MDLMaterial?, semantic: MDLMaterialSemantic) -> MTLTexture? {
        guard let property = material?.property(with: semantic),
            property.type == .string,
            let fileName = property.stringValue else {
                return nil
        }
        return Texture.loadTexture(imageNamed: fileName)
    }
    
    init(material: MDLMaterial?) {
        color = Texture.property(with: material, semantic: .baseColor)
        normal = Texture.property(with: material, semantic: .tangentSpaceNormal)
        roughness = Texture.property(with: material, semantic: .roughness)
        metallic = Texture.property(with: material, semantic: .metallic)
        ambientOcclusion = Texture.property(with: material, semantic: .ambientOcclusion)
    }
}

extension Texture {
    static func loadTexture(imageNamed name: String, device: MTLDevice? = MTLCreateSystemDefaultDevice()) -> MTLTexture? {
        guard let device = device else {
            fatalError("load texture failed because the device is not available")
        }
        
        let textureLoader = MTKTextureLoader(device: device)
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [.origin: MTKTextureLoader.Origin.bottomLeft,
                                                                    .SRGB: false,
                                                                    .generateMipmaps: NSNumber(booleanLiteral: true)]
        var texture: MTLTexture?
        
        let fileExtension = URL(fileURLWithPath: name).pathExtension.isEmpty ? "png" : nil
        let url = Bundle.main.url(forResource: name, withExtension: fileExtension)
        
        if let url = url {
            do {
                texture = try textureLoader.newTexture(URL: url, options: textureLoaderOptions)
            } catch {
                print("load texture \(name) failed, reason: \(error.localizedDescription) ")
            }
        }else {
            do {
                texture = try textureLoader.newTexture(name: name, scaleFactor: 1.0,
                                              bundle: Bundle.main, options: nil)
            } catch {
                print("load texture \(name) failed, reason: \(error.localizedDescription) ")
            }
        }
        
        return texture
    }
    
    static func loadCubeTexture(imageName: String) -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: Renderer.device)
        if let texture = MDLTexture(cubeWithImagesNamed: [imageName]) {
            let options: [MTKTextureLoader.Option: Any] =
                [.origin: MTKTextureLoader.Origin.topLeft,
                 .SRGB: false,
                 .generateMipmaps: NSNumber(booleanLiteral: false)]
            return try? textureLoader.newTexture(texture: texture, options: options)
        }
        
        let texture = try? textureLoader.newTexture(name: imageName, scaleFactor: 1.0,
                                                   bundle: .main)
        return texture
    }
    
    static func newTexture(pixelFormat: MTLPixelFormat, size: CGSize, label: String) -> MTLTexture? {
        guard size.width != .zero && size.height != .zero else { return nil }
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: Int(size.width), height: Int(size.height), mipmapped: false)
        descriptor.usage = [.shaderRead, .renderTarget, .shaderWrite]
        descriptor.storageMode = .private
        guard let texture = Renderer.device.makeTexture(descriptor: descriptor) else {
            fatalError("new texture failed")
        }
        
        texture.label = label
        return texture
    }
}

extension Material {
    init(material: MDLMaterial?) {
        self.init()
        if let baseColor = material?.property(with: .baseColor),
            baseColor.type == .float3 {
            self.baseColor = baseColor.float3Value
        }
        if let specular = material?.property(with: .specular),
            specular.type == .float3 {
            self.specularColor = specular.float3Value
        }
        if let shininess = material?.property(with: .specularExponent),
            shininess.type == .float {
            self.shininess = shininess.floatValue
        }
        if let roughness = material?.property(with: .roughness),
            roughness.type == .float {
            self.roughness = roughness.floatValue
        }
        if let metallic = material?.property(with: .metallic),
            metallic.type == .float {
            self.metallic = metallic.floatValue
        }
        if let ao = material?.property(with: .ambientOcclusion),
            ao.type == .float3 {
            self.ambientOcclusion = ao.float3Value
        }
    }
}
