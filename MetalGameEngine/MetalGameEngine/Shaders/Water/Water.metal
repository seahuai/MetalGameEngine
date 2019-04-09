//
//  Water.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/9.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../Header/Common.h"

struct VertexIn {
    float4 position [[ attribute(0) ]];
    float2 uv [[ attribute(2) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float2 uv;
    float3 worldPosition;
};

vertex VertexOut vertex_water(VertexIn in [[ stage_in ]],
                             constant Uniforms &uniforms [[ buffer(BufferIndexUniforms) ]]) {
    VertexOut out;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.position;
    out.uv = in.uv;
    out.worldPosition = (uniforms.modelMatrix * in.position).xyz;
    return out;
}

fragment float4 fragment_water(VertexOut in [[ stage_in ]],
                               constant FragmentUniforms &fragementUniforms [[ buffer(BufferIndexFragmentUniforms) ]]) {
    return float4(0, 0, 1, 1);
}


