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
    
    // Const
    let maxFrameInFlight = 3
    let semaphore: DispatchSemaphore
    
    // Ray
    var rayCount: Int = 0
    var rayStride = MemoryLayout<MPSRayOriginMinDistanceDirectionMaxDistance>.stride + MemoryLayout<float3>.stride
    var rayBuffer: MTLBuffer!
    var rayGeneratorComputePipelineState: MTLComputePipelineState!
    
    // Intersection
    var intersectionStride = MemoryLayout<MPSIntersectionDistancePrimitiveIndexCoordinates>.stride
    var intersectionBuffer: MTLBuffer!
    var intersectionComputePipelinseState: MTLComputePipelineState!
    
    // Shadow Ray
    var shadowRayBuffer: MTLBuffer!
    var shadowComputePipelineState: MTLComputePipelineState!
    
    // Accumulate
    var frameIndex: Int = 0
    var accumulateRenderTarget: MTLTexture!
    var accumulateComputePipelieState: MTLComputePipelineState!
    
    // MPS
    var accelerationStructure: MPSTriangleAccelerationStructure!
    var rayIntersector: MPSRayIntersector!
    
    // Render Target
    var renderTargetSize: MTLSize!
    var renderTarget: MTLTexture!
    
    // Light
    var hasDirectionalLight = false
    var light = Light()
    
    // Random
    let randomBufferCapacity = 256
    lazy var randomBufferStride: Int = {
        return MemoryLayout<float2>.stride * self.randomBufferCapacity
    }()
    var randomBuffer: MTLBuffer!
    var randomBufferOffset = 0
    
    // Buffer Index
    var bufferIndex = 0
    
    // Bilt
    var biltRenderPipelineState: MTLRenderPipelineState!
    
    var isAccelerationStructureDataReady = false
    var rayTracingUsedBuffer: Scene.VerticesBuffer?
    
    required init(metalView: GameView, scene: Scene) {
        
        semaphore = DispatchSemaphore.init(value: maxFrameInFlight)
        
        super.init(metalView: metalView, scene: scene)
        
        scene.delegate = self
        
        let randomBufferSize = randomBufferStride * maxFrameInFlight
        randomBuffer = Renderer.device.makeBuffer(length: randomBufferSize, options: .storageModeManaged)!
        
        buildPipelineState()
        
        buildRenderTarget(metalView.drawableSize)
        
        mtkView(drawableSizeWillChange: metalView.drawableSize)
    }
    
    override func mtkView(drawableSizeWillChange size: CGSize) {
        // 更新射线数量，一个像素一条射线
        rayCount = Int(size.width) * Int(size.height)
        
        frameIndex = 0
        
        buildRenderTarget(size)
        
        buildBuffers(rayCount)
    }
    
    override func draw(with mainPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {
        
        // 数据就绪才开始进行渲染操作
        guard isAccelerationStructureDataReady else { return }
        
        // 添加信号量
        semaphore.wait()
        commandBuffer.addCompletedHandler { cb in
            self.semaphore.signal()
        }
        
        // 更新 Buffer
        updateBuffers()
        
        // 1. 生成射线
        dispatchComputeOperation(rayGeneratorComputePipelineState,
                                 commandBuffer: commandBuffer) { (computeEncoder) in
                                    computeEncoder.label = "Ray Generator"
                                    computeEncoder.setTexture(renderTarget, index: 0)
                                    computeEncoder.setBuffer(rayBuffer, offset: 0, index: 0)
                                    computeEncoder.setBuffer(randomBuffer, offset: randomBufferOffset, index: 1)
        }
        
        for _ in 0..<3 {
            
            // 2. 使用 MPS 计算射线与三角形的相交
            rayIntersector.label = "Intersectort"
            rayIntersector.intersectionDataType = .distancePrimitiveIndexCoordinates
            rayIntersector.encodeIntersection(commandBuffer: commandBuffer,
                                              intersectionType: .nearest,
                                              rayBuffer: rayBuffer, rayBufferOffset: 0,
                                              intersectionBuffer: intersectionBuffer, intersectionBufferOffset: 0,
                                              rayCount: rayCount,
                                              accelerationStructure: accelerationStructure)
            
            // 3. 处理得到的数据
            let normalsBuffer = rayTracingUsedBuffer?.normalsBuffer
            let colorsBuffer = rayTracingUsedBuffer?.colorsBuffer
            dispatchComputeOperation(intersectionComputePipelinseState,
                                     commandBuffer: commandBuffer) { (computeEncoder) in
                                        computeEncoder.label = "Handle Intersection"
                                        computeEncoder.setTexture(renderTarget, index: 0)
                                        computeEncoder.setBuffer(intersectionBuffer, offset: 0, index: 0)
                                        computeEncoder.setBuffer(rayBuffer, offset: 0, index: 1)
                                        computeEncoder.setBuffer(normalsBuffer, offset: 0, index: 2)
                                        computeEncoder.setBuffer(colorsBuffer, offset: 0, index: 3)
                                        computeEncoder.setBuffer(shadowRayBuffer, offset: 0, index: 4)
                                        computeEncoder.setBytes(&light, length: MemoryLayout<Light>.stride, index: 5)
                                        computeEncoder.setBytes(&hasDirectionalLight, length: MemoryLayout<Bool>.size, index: 6)
                                        computeEncoder.setBuffer(randomBuffer, offset: randomBufferOffset, index: 7)
            }
            
            // 4. 处理阴影
            if hasDirectionalLight {
                rayIntersector.label = "Shadow Intersector"
                rayIntersector.intersectionDataType = .distance
                rayIntersector.encodeIntersection(commandBuffer: commandBuffer,
                                                  intersectionType: .any,
                                                  rayBuffer: shadowRayBuffer, rayBufferOffset: 0,
                                                  intersectionBuffer: intersectionBuffer, intersectionBufferOffset: 0,
                                                  rayCount: rayCount,
                                                  accelerationStructure: accelerationStructure)
                
                dispatchComputeOperation(shadowComputePipelineState,
                                         commandBuffer: commandBuffer) { (computeEncoder) in
                                            computeEncoder.label = "Shadow Kernal"
                                            computeEncoder.setTexture(renderTarget, index: 0)
                                            computeEncoder.setBuffer(shadowRayBuffer, offset: 0, index: 0)
                                            computeEncoder.setBuffer(intersectionBuffer, offset: 0, index: 1)
                }
            }
            
            // 5. 降噪
            dispatchComputeOperation(accumulateComputePipelieState,
                                     commandBuffer: commandBuffer) { (computeEncoder) in
                                        computeEncoder.label = "Accumulate"
                                        computeEncoder.setTexture(renderTarget, index: 0)
                                        computeEncoder.setTexture(accumulateRenderTarget, index: 1)
                                        computeEncoder.setBytes(&frameIndex, length: MemoryLayout<Int>.size, index: 1)
                                        
            }
            
        }
        
        // 6. 将 renderTarget 复制到 drawable texture 上
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: mainPassDescriptor) else {
            return
        }
        
        renderEncoder.setRenderPipelineState(biltRenderPipelineState)
        renderEncoder.setFragmentTexture(accumulateRenderTarget, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        
        renderEncoder.endEncoding()
        
        frameIndex += 1
    }
}

// MARK: - Method
private extension RayTracingRenderer {
    func dispatchComputeOperation(_ computePipelineState: MTLComputePipelineState,
                                  commandBuffer: MTLCommandBuffer,
                                  setupDataBlock: ( (MTLComputeCommandEncoder) -> ()) ) {
        
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
        setupDataBlock(computeEncoder)
        computeEncoder.setComputePipelineState(computePipelineState)
        computeEncoder.dispatchThreads(renderTargetSize, threadsPerThreadgroup: MTLSize(width: 8, height: 8, depth: 1))
        computeEncoder.endEncoding()
    }
    
    func updateBuffers() {
        updateRandomBuffer()
        bufferIndex += 1
        bufferIndex %= maxFrameInFlight
    }
    
    func updateRandomBuffer() {
        randomBufferOffset = randomBufferStride * bufferIndex
        var randomBufferPointer = randomBuffer.contents().advanced(by: randomBufferOffset).bindMemory(to: float2.self, capacity: randomBufferCapacity)
        for _ in 0..<randomBufferCapacity {
            // 产生一个随机的 float2 值
            randomBufferPointer.pointee = float2(Float(drand48()), Float(drand48()))
            randomBufferPointer = randomBufferPointer.advanced(by: 1)
        }
        randomBuffer.didModifyRange(randomBufferOffset..<(randomBufferOffset + randomBufferStride))
    }
}

// MARK: - Build
private extension RayTracingRenderer {
    func buildPipelineState() {
        let rayGeneratorFunction = Renderer.library!.makeFunction(name: "generateRays")!
        let intersectionFunction = Renderer.library!.makeFunction(name: "handleIntersecitons")!
        let shadowFunction = Renderer.library!.makeFunction(name: "shadowKernal")!
        let accumulateFunction = Renderer.library!.makeFunction(name: "accumulateKernal")!
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = Renderer.library?.makeFunction(name: "vertexShader")
        descriptor.fragmentFunction = Renderer.library?.makeFunction(name: "fragmentShader")
        descriptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat
        descriptor.depthAttachmentPixelFormat = Renderer.depthPixelFormat
        
        do {
            rayGeneratorComputePipelineState = try Renderer.device.makeComputePipelineState(function: rayGeneratorFunction)
            intersectionComputePipelinseState = try Renderer.device.makeComputePipelineState(function: intersectionFunction)
            shadowComputePipelineState = try Renderer.device.makeComputePipelineState(function: shadowFunction)
            accumulateComputePipelieState = try Renderer.device.makeComputePipelineState(function: accumulateFunction)
            biltRenderPipelineState = try Renderer.device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func buildBuffers(_ rayCount: Int) {
        rayBuffer = Renderer.device.makeBuffer(length: rayStride * rayCount, options: .storageModePrivate)
        shadowRayBuffer = Renderer.device.makeBuffer(length: rayStride * rayCount, options: .storageModePrivate)
        intersectionBuffer = Renderer.device.makeBuffer(length: intersectionStride * rayCount, options: .storageModePrivate)
    }
    
    func buildRenderTarget(_ size: CGSize) {
        renderTargetSize = MTLSize(width: Int(size.width), height: Int(size.height), depth: 1)
        renderTarget = Texture.newTexture(pixelFormat: .rgba32Float, size: size, label: "Ray Tracing Render Target")
        accumulateRenderTarget = Texture.newTexture(pixelFormat: .rgba32Float, size: size, label: "Ray Tracing Accumulate Render Targer")
    }
    
    func buildRayIntersectionStructure() {
        rayTracingUsedBuffer = scene.rayTracingUsedBuffer()
        
        guard let device = Renderer.device, let vertexBuffer = rayTracingUsedBuffer else {
            isAccelerationStructureDataReady = false
            return
        }
        isAccelerationStructureDataReady = true
        
        // MARK: - Setup Acceleration Structure
        accelerationStructure = MPSTriangleAccelerationStructure(device: device)
        accelerationStructure.vertexBuffer = vertexBuffer.positionsBuffer
        accelerationStructure.vertexStride = MemoryLayout<float3>.stride
        accelerationStructure.triangleCount = vertexBuffer.triangleCount
        accelerationStructure.rebuild()
        
        // MARK: - Setup Intersection Structure
        rayIntersector = MPSRayIntersector(device: device)
        rayIntersector.rayStride = rayStride
    }
}

extension RayTracingRenderer: SceneDelegate {
    func scene(_ scene: Scene, didChangeRayTracingModels: [RayTracingModel]) {
        buildRayIntersectionStructure()
    }
    
    func scene(_ scnee: Scene, didChangeLights lights: [Light]) {
        if let light = (scene.lights.first{ $0.type == Sunlight && $0.isAreaLight == 1 }) {
            self.light = light
            // 增幅
            self.light.color *= 4
            hasDirectionalLight = true
        } else {
            hasDirectionalLight = false
        }
    }
}


