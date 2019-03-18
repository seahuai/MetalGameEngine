//
//  Renderer.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/18.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

// MARK: Base Class

class Renderer: NSObject {
    
    final let metalView: MTKView
    final let device: MTLDevice
    final let commandQueue: MTLCommandQueue
    
    init(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
                fatalError("GPU not available")
        }
        
        self.metalView = metalView
        
        self.device = device
        
        self.commandQueue = commandQueue
        
        metalView.device = device
        
        super.init()
    }
}
