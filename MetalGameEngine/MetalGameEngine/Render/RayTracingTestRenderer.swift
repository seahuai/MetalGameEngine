//
//  RayTracingTestRenderer.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/18.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit
import MetalPerformanceShaders

class RayTracingTestRenderer: Renderer {
    
    // Ray
    var rayCount: Int = 0
    var rayStride = MemoryLayout<MPSRayOriginMinDistanceDirectionMaxDistance>.stride
    var rayBuffer: MTLBuffer!
    var rayGeneratorComputePipelineState: MTLComputePipelineState!
    
    // Intersection
    var intersectionDataType: MPSIntersectionDataType = .distancePrimitiveIndexCoordinates
    var intersectionStride = MemoryLayout<MPSIntersectionDistancePrimitiveIndexCoordinates>.stride
    var intersectionBuffer: MTLBuffer!
    var intersectionComputePipelinseState: MTLComputePipelineState!
    
    // MPS
    var accelerationStructure: MPSTriangleAccelerationStructure!
    var rayIntersector: MPSRayIntersector!
    
    // Render Target
    var renderTargetSize: MTLSize!
    var renderTarget: MTLTexture!
    
    // Bilt
    var biltRenderPipelineState: MTLRenderPipelineState!
    
    required init(metalView: MTKView, scene: Scene) {
        super.init(metalView: metalView, scene: scene)
        
        buildPipelineState()
        
        buildRenderTarget(metalView.drawableSize)
        
        buildRayIntersectionStructure()
    }
    
    override func mtkView(drawableSizeWillChange size: CGSize) {
        buildRenderTarget(size)
        
        // 更新射线数量，一个像素一条射线
        rayCount = Int(size.width) * Int(size.height)
        buildBuffers(rayCount)
    }
    
    override func draw(with mainPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {
        
        // 1. 生成射线
        dispatchComputeOperation(rayGeneratorComputePipelineState,
                                 commandBuffer: commandBuffer) { (computeEncoder) in
            computeEncoder.label = "Ray Generator"
            computeEncoder.setBuffer(rayBuffer, offset: 0, index: 0)
        }
        
        // 2. 使用 MPS 计算射线与三角形的相交
        rayIntersector.encodeIntersection(commandBuffer: commandBuffer,
                                          intersectionType: .nearest,
                                          rayBuffer: rayBuffer, rayBufferOffset: 0,
                                          intersectionBuffer: intersectionBuffer, intersectionBufferOffset: 0,
                                          rayCount: rayCount,
                                          accelerationStructure: accelerationStructure)
        
        // 3. 处理得到的数据
        dispatchComputeOperation(intersectionComputePipelinseState,
                                 commandBuffer: commandBuffer) { (computeEncoder) in
            computeEncoder.label = "Handle Intersection"
            computeEncoder.setTexture(renderTarget, index: 0)
            computeEncoder.setBuffer(intersectionBuffer, offset: 0, index: 0)
        }
        
        // 4. 将 renderTarget 复制到 drawable texture 上
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: mainPassDescriptor) else {
            return
        }
        
        renderEncoder.setRenderPipelineState(biltRenderPipelineState)
        renderEncoder.setFragmentTexture(renderTarget, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        
        renderEncoder.endEncoding()
    }
}

// MARK: - Method
private extension RayTracingTestRenderer {
    func dispatchComputeOperation(_ computePipelineState: MTLComputePipelineState,
                                  commandBuffer: MTLCommandBuffer,
                                  setupDataBlock: ( (MTLComputeCommandEncoder) -> ()) ) {
        
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
        setupDataBlock(computeEncoder)
        computeEncoder.setComputePipelineState(computePipelineState)
        computeEncoder.dispatchThreads(renderTargetSize, threadsPerThreadgroup: MTLSize(width: 8, height: 8, depth: 1))
        computeEncoder.endEncoding()
    }
}

// MARK: - Build
private extension RayTracingTestRenderer {
    func buildPipelineState() {
        let rayGeneratorFunction = Renderer.library!.makeFunction(name: "generateRays")!
        let intersectionFunction = Renderer.library!.makeFunction(name: "handleIntersecitons")!
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = Renderer.library?.makeFunction(name: "vertexShader")
        descriptor.fragmentFunction = Renderer.library?.makeFunction(name: "fragmentShader")
        descriptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
        descriptor.depthAttachmentPixelFormat = Renderer.depthPixelFormat
        
        do {
            rayGeneratorComputePipelineState = try Renderer.device.makeComputePipelineState(function: rayGeneratorFunction)
            intersectionComputePipelinseState = try Renderer.device.makeComputePipelineState(function: intersectionFunction)
            biltRenderPipelineState = try Renderer.device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func buildBuffers(_ rayCount: Int) {
        rayBuffer = Renderer.device.makeBuffer(length: rayStride * rayCount, options: .storageModePrivate)
        intersectionBuffer = Renderer.device.makeBuffer(length: intersectionStride * rayCount, options: .storageModePrivate)
    }
    
    func buildRenderTarget(_ size: CGSize) {
        renderTargetSize = MTLSize(width: Int(size.width), height: Int(size.height), depth: 1)
        renderTarget = Texture.newTexture(pixelFormat: .rgba32Float, size: size, label: "Ray Tracing Render Target")
    }
    
    
    func buildRayIntersectionStructure() {
        let device = Renderer.device!
        let vertices: [Float] = [
            0.0, 0.5, 0.0,
            -0.5, -0.5, 0.0,
            0.5, -0.5, 0
        ]
        
        let indices: [UInt32] = [0, 1, 2]
        
        let vertexBuffer = Renderer.device.makeBuffer(bytes: vertices, length: MemoryLayout<float3>.stride * 3, options: .storageModeManaged)
        let indexBuffer = Renderer.device.makeBuffer(bytes: indices, length: MemoryLayout<UInt32>.size * indices.count, options: .storageModeManaged)
        
        // MARK: - Setup Acceleration Structure
        accelerationStructure = MPSTriangleAccelerationStructure(device: device)
        accelerationStructure.vertexBuffer = vertexBuffer
        accelerationStructure.vertexStride = MemoryLayout<float3>.stride
        accelerationStructure.indexBuffer = indexBuffer
        accelerationStructure.indexType = .uInt32
        accelerationStructure.triangleCount = 1
        accelerationStructure.rebuild()
        
        // MARK: - Setup Intersection Structure
        rayIntersector = MPSRayIntersector(device: device)
        rayIntersector.rayStride = rayStride
        rayIntersector.intersectionDataType = intersectionDataType
        rayIntersector.intersectionStride = intersectionStride
    }
}


