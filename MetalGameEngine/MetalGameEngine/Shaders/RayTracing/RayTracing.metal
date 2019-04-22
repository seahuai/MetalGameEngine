//
//  RayTracing.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/18.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Ray {
    packed_float3 origin;
    float minDistance;
    packed_float3 direction;
    float maxDistance;
    float3 color;
};

struct Intersection {
    float distance;
    uint primitiveIndex;
    float2 coordinates;
};

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
                                uint2 position [[ thread_position_in_grid ]],
                                uint2 size [[ threads_per_grid ]]) {
    uint index = position.x + position.y * size.x;
    Intersection intersection = intersections[index];
    // 相交则大于0
    if (intersection.distance > 0) {
        float2 coordinates = intersection.coordinates;
        float w = 1 - coordinates.x - coordinates.y;
//        renderTarget.write(float4(coordinates, w, 1.0), position);
        renderTarget.write(float4(1.0), position);
    }
}

