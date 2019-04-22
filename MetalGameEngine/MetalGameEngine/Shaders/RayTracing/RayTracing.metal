//
//  RayTracing.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/18.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#import "RayTracingStructure.h"

// MARK: - Method Define
template<typename T>
inline T interpolateVertexAttribute(device T *attributes, Intersection intersection);

// MARK: - Shdaer
kernel void generateRays(device Ray *rays [[ buffer(0) ]],
                         uint2 position [[ thread_position_in_grid ]],
                         uint2 size [[threads_per_grid ]])
{
    // ray index
    uint index = position.x + position.y * size.x;
    
    // convert position to (-1, 1)
    float2 uv = float2(position) / float2(size - 1);
    uv = uv * 2.0 - 1.0;
    
    // camera origin
    float3 origin = float3(0.0, 1.0, 2.0);
    float aspect = float(size.y) / float(size.x);
    float3 direction = float3(uv.x, uv.y * aspect, -1.0);
    direction = normalize(direction);
    
    rays[index].origin = origin;
    rays[index].direction = direction;
    rays[index].minDistance = 0.0;
    rays[index].maxDistance = INFINITY;
    rays[index].color = float3(1);
    
}

kernel void handleIntersecitons(texture2d<float, access::write> renderTarget [[ texture(0) ]],
                                device Intersection *intersections [[ buffer(0) ]],
                                device Ray *rays [[ buffer(1) ]],
                                device float3 *normals [[ buffer(2) ]],
                                device float3 *colors [[ buffer(3) ]],
                                uint2 position [[ thread_position_in_grid ]],
                                uint2 size [[ threads_per_grid ]]) {
    uint index = position.x + position.y * size.x;
    device Intersection &intersection = intersections[index];
    device Ray &ray = rays[index];
    float3 color = ray.color;
    
    if (intersection.distance > 0) {
        // 颜色插值
        color *= interpolateVertexAttribute(colors, intersection);
        ray.color = color;
    }
}

// MARK: - Method

// Interpolates vertex attribute of an arbitrary type across the surface of a triangle
// given the barycentric coordinates and triangle index in an intersection struct
template<typename T>
inline T interpolateVertexAttribute(device T *attributes, Intersection intersection) {
    float3 uvw;
    uvw.xy = intersection.coordinates;
    uvw.z = 1.0 - uvw.x - uvw.y;
    unsigned int triangleIndex = intersection.primitiveIndex;
    T T0 = attributes[triangleIndex * 3 + 0];
    T T1 = attributes[triangleIndex * 3 + 1];
    T T2 = attributes[triangleIndex * 3 + 2];
    return uvw.x * T0 + uvw.y * T1 + uvw.z * T2;
}
