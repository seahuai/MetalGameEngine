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
    }
}
