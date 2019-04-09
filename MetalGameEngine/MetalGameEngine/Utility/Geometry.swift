//
//  Geometry.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/9.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class Geometry {
    
    private static let shared = Geometry()!
    
    private let device: MTLDevice!
    private let allocator: MTKMeshBufferAllocator!
    
    init?() {
        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
        
        self.device = device
        
        let allocator = MTKMeshBufferAllocator(device: device)
        self.allocator = allocator
    }
    
    static func plane(size: float2) -> MTKMesh {
        let plane = MDLMesh.newPlane(withDimensions: size, segments: [1, 1], geometryType: .triangles, allocator: shared.allocator)
        let mesh: MTKMesh
        do {
            mesh = try MTKMesh(mesh: plane, device: shared.device)
        } catch {
            fatalError(error.localizedDescription)
        }
        return mesh
    }
    
    
}
