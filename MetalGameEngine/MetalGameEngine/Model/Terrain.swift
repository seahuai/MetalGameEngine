//
//  Terrian.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/29.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class Terrain: Node {
    
    let maxTessellationFactors = 64
    
    var isWireframe = false
    
    var patchSize: float2 = [8, 8] {
        didSet {
            buildControlPointsBuffers()
        }
    }
    
    var height: Float = 1
    
    let patches: (horizontal: Int, vertical: Int)
    var patchCount: Int {
        return patches.horizontal * patches.vertical
    }
    var edgeFactors: [Float] = [4]
    var insideFactors: [Float] = [4]
    
    private let heightMap: MTLTexture
    
    private var controlPointsBuffer: MTLBuffer?
    private lazy var tessellationFactorsBuffer: MTLBuffer? = {
        let count = self.patchCount * (4 + 2)
        // in compute kernal use 'half float'
        let length = (MemoryLayout<Float>.size / 2) * count
        let buffer = Renderer.device.makeBuffer(length: length, options: .storageModePrivate)
        return buffer
    }()
    
    private var depthStencilState: MTLDepthStencilState!
    private var renderPipelineState: MTLRenderPipelineState!
    private var computePipelineState: MTLComputePipelineState!
    
    private var terrainData: TerrainData!
    private var uniforms: Uniforms!
    
    init(heightMapName: String,
         size: float2 = [8, 8],
         height: Float = 1,
         patches: (horizontal: Int, vertical: Int) = (6, 6)) {
        guard let heightMap = Texture.loadTexture(imageNamed: heightMapName) else {
            fatalError("Height Map \(heightMapName) not available")
        }
        
        self.heightMap = heightMap
        self.patchSize = size
        self.height = height
        self.patches = patches
        
        super.init()
        
        self.name = "Terrain \(heightMapName)"
        
        buildControlPointsBuffers()
        
        buildDepthStencilState()
        
        buildComputePipelineState()
        
        buildRenderPipelineState()
    }
    
    func compute(mainPassDescriptor: MTLRenderPassDescriptor,
                commandBuffer: MTLCommandBuffer,
                uniforms: Uniforms,
                cameraPosition: float3) {
        
        self.uniforms = uniforms
        self.uniforms.modelMatrix = self.modelMatrix
        
        var cameraPosition = cameraPosition
        
        terrainData = TerrainData(size: self.patchSize, height: self.height, maxTessellation: uint(self.maxTessellationFactors))
        
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
        
        computeEncoder.pushDebugGroup("Terrain Compute")
        // compute
        computeEncoder.setComputePipelineState(computePipelineState)
        
        computeEncoder.setBytes(&edgeFactors, length: MemoryLayout<Float>.size * edgeFactors.count, index: 0)
        computeEncoder.setBytes(&insideFactors, length: MemoryLayout<Float>.size * insideFactors.count, index: 1)
        computeEncoder.setBuffer(tessellationFactorsBuffer, offset: 0, index: 2)
        computeEncoder.setBytes(&cameraPosition, length: MemoryLayout<float3>.stride, index: 3)
        computeEncoder.setBytes(&self.uniforms, length: MemoryLayout<Uniforms>.stride, index: 4)
        computeEncoder.setBuffer(controlPointsBuffer, offset: 0, index: 5)
        computeEncoder.setBytes(&terrainData, length: MemoryLayout<TerrainData>.stride, index: 6)
        
        let width = min(computePipelineState.threadExecutionWidth, patchCount)
        computeEncoder.dispatchThreadgroups(MTLSize(width: patchCount, height: 1, depth: 1), threadsPerThreadgroup: MTLSize(width: width, height: 1, depth: 1))
        
        computeEncoder.endEncoding()
        computeEncoder.popDebugGroup()
    }
    
    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.pushDebugGroup("Terrain")
        
        renderEncoder.setDepthStencilState(depthStencilState)
        
        // render
        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.setTriangleFillMode(isWireframe ? .lines : .fill)
        
        renderEncoder.setVertexBuffer(controlPointsBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        renderEncoder.setVertexBytes(&terrainData, length: MemoryLayout<TerrainData>.stride, index: 2)
        renderEncoder.setVertexTexture(heightMap, index: 0)
        renderEncoder.setTessellationFactorBuffer(tessellationFactorsBuffer, offset: 0, instanceStride: 0)
        
        renderEncoder.drawPatches(numberOfPatchControlPoints: 4, patchStart: 0, patchCount: patchCount, patchIndexBuffer: nil, patchIndexBufferOffset: 0, instanceCount: 1, baseInstance: 0)
        
        renderEncoder.popDebugGroup()
    }
}

private extension Terrain {
    func buildDepthStencilState() {
        let desciptor = MTLDepthStencilDescriptor()
        desciptor.depthCompareFunction = .lessEqual
        desciptor.isDepthWriteEnabled = true
        depthStencilState = Renderer.device.makeDepthStencilState(descriptor: desciptor)
    }
    
    
    func buildComputePipelineState() {
        guard let kernalFunction = Renderer.library?.makeFunction(name: "tessellation_main") else {
            fatalError()
        }
        
        do {
            computePipelineState = try Renderer.device.makeComputePipelineState(function: kernalFunction)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func buildRenderPipelineState() {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        descriptor.depthAttachmentPixelFormat = .depth32Float
        
        descriptor.vertexFunction = Renderer.library?.makeFunction(name: "tessellation_vertex")
        descriptor.fragmentFunction = Renderer.library?.makeFunction(name: "tessellation_fragment")
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.layouts[0].stepFunction = .perPatchControlPoint
        vertexDescriptor.layouts[0].stride = MemoryLayout<float3>.stride
        
        descriptor.vertexDescriptor = vertexDescriptor
        descriptor.tessellationFactorStepFunction = .perPatch
        descriptor.maxTessellationFactor = maxTessellationFactors
        descriptor.tessellationPartitionMode = .pow2
        
        do {
            renderPipelineState = try Renderer.device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func buildControlPointsBuffers() {
        let controlPoints = creatControlPoints()
        controlPointsBuffer = Renderer.device.makeBuffer(bytes: controlPoints, length: MemoryLayout<float3>.stride * controlPoints.count, options: [])
    }
    
    func creatControlPoints() -> [float3] {
        var points: [float3] = []
        
        let unitWidth = 1 / Float(patches.horizontal)
        let unitHeight = 1 / Float(patches.vertical)
        
        for i in 0..<patches.horizontal {
            let row = Float(i)
            for j in 0..<patches.vertical {
                let column = Float(j)
                let left = column * unitWidth
                let bottom = row * unitHeight
                let right = left + unitWidth
                let top = bottom + unitHeight
                
                points.append([left, 0, top])
                points.append([right, 0, top])
                points.append([right, 0, bottom])
                points.append([left, 0, bottom])
            }
        }
        
        let size = self.patchSize
        points = points.map{
            [$0.x * size.x - size.x / 2, 0, $0.z * size.y - size.y / 2]
        }
        
        return points
    }
}
