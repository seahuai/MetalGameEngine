//
//  Bilt.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/19.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[ position ]];
    float2 uv;
};

constant float2 quadVertices[] = {
    float2(-1, -1),
    float2(-1,  1),
    float2( 1,  1),
    float2(-1, -1),
    float2( 1,  1),
    float2( 1, -1)
};

vertex VertexOut vertexShader(uint vid [[ vertex_id ]])
{
    float2 position = quadVertices[vid];
    VertexOut out;
    out.position = float4(position, 0, 1);
    out.uv = position * 0.5 + 0.5;
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               texture2d<float> tex)
{
    constexpr sampler s(min_filter::nearest, mag_filter::nearest, mip_filter::none);
    float3 color = tex.sample(s, in.uv).xyz;
    return float4(color, 1.0);
}
