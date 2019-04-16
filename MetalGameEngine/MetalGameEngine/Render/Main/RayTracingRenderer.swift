//
//  RayTracingRenderer.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/16.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit
import MetalPerformanceShaders

class RayTracingRenderer: Renderer {
    
    // main pipeline
    private var renderPipeline: MTLRenderPipelineState!
    
    // rays
    private var rayComputePipeline: MTLComputePipelineState!
    private var raysBuffer: MTLBuffer!
    
    // shadow
    private var shadeComputePipeline: MTLComputePipelineState!
    private var shadowComputePipeline: MTLComputePipelineState!
    private var shadowRaysBuffer: MTLBuffer!
    
    // accumulate
    private var accumulateComputePipeline: MTLComputePipelineState!
    private var accumulationTarget: MTLTexture!
    
    // accelerate
    private var accelerationStructure: MPSTriangleAccelerationStructure!
    
    required init(metalView: MTKView, scene: Scene) {
        super.init(metalView: metalView, scene: scene)
    }
    
    private func buildPipeline() {
        
    }

}
