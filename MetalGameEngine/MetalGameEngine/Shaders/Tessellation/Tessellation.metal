//
//  Tessellation.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/29.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../Header/Common.h"

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
    float height;
    float2 uv;
};

struct ControlPoint {
    float4 position [[ attribute(0) ]];
};


float distanceBetweenPointAndLine(float3 pointa, float3 pointb, float3 point, float4x4 matrix) {
    float3 a = (float4(pointa, 1) * matrix).xyz;
    float3 b = (float4(pointb, 1) * matrix).xyz;
    float3 lineMidPoint = (a + b) * 0.5;
    float dis = distance(lineMidPoint, point);
    return dis;
}

kernel void tessellation_main(constant float *edgeFactors [[ buffer(0) ]],
                              constant float *insideFactors [[ buffer(1) ]],
                              device MTLQuadTessellationFactorsHalf *factors [[ buffer(2) ]],
                              constant float3 &cameraPosition [[ buffer(3) ]],
                              constant Uniforms &uniforms [[ buffer(4) ]],
                              constant float3 *controlPoints [[ buffer(5) ]],
                              constant TerrainData &terrain [[ buffer(6) ]],
                              uint pid [[ thread_position_in_grid ]])
{
    uint index = pid * 4;
    float total = 0;
    for (uint i = 0; i < 4; i ++ ) {
        uint aIndex = i;
        uint bIndex = aIndex + 1;
        if (bIndex == 4) {
            bIndex = 0;
        }
        uint edgeIndex = bIndex;
        
        float3 pointA = controlPoints[aIndex + index];
        float3 pointB = controlPoints[bIndex + index];
        float dis = distanceBetweenPointAndLine(pointA, pointB, cameraPosition, uniforms.modelMatrix);
        
        float tessellation = max(4.0, terrain.maxTessellation / dis);
        factors[pid].edgeTessellationFactor[edgeIndex] = tessellation;
        
        total += tessellation;
    }
    
    factors[pid].insideTessellationFactor[0] = total * 0.25;
    factors[pid].insideTessellationFactor[1] = total * 0.25;
}



[[ patch(quad, 4)]]
vertex VertexOut tessellation_vertex(patch_control_point<ControlPoint> controlPoints [[ stage_in ]],
                                     constant Uniforms &uniforms [[ buffer(1) ]],
                                     constant TerrainData &terrain [[ buffer(2) ]],
                                     texture2d<float> heightMap [[ texture(0) ]],
                                     uint patchId [[ patch_id ]],
                                     float2 patchCood [[ position_in_patch ]])
{
    VertexOut out;
    float u = patchCood.x;
    float v = patchCood.y;
    
    float2 top = mix(controlPoints[0].position.xz, controlPoints[1].position.xz, u);
    float2 bottom = mix(controlPoints[3].position.xz, controlPoints[2].position.xz, u);
    float2 interpolated = mix(top, bottom, v);
    
    float4 position = float4(interpolated.x, 0, interpolated.y, 1);
    
    constexpr sampler sample;
    float2 uv = (interpolated + terrain.size * 0.5) / terrain.size;
    float4 color = heightMap.sample(sample, uv);
    out.color = float4(color.r);
    
    float height = (color.r * 2 - 1) * terrain.height;
    position.y = height;
    
    float4x4 mvp = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix;
    out.position = mvp * position;
    out.uv = uv;
    out.height = height;
    
    return out;
}

fragment float4 tessellation_fragment(VertexOut in [[ stage_in ]])
{
    return float4(in.color.rgb, 1);
}
