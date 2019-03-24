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
    
    let mtkSubmesh: MTKSubmesh
    
    init(mtkSubmesh: MTKSubmesh, mdlsubmesh: MDLSubmesh, vertexDescriptor: MDLVertexDescriptor) {
        self.mtkSubmesh = mtkSubmesh
        
        self.texture = Texture(material: mdlsubmesh.material)
        self.material = Material(material: mdlsubmesh.material)
        self.vertexDescriptor = vertexDescriptor
    }
}
