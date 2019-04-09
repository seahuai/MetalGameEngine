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
                               constant float4 &waterColor [[ buffer(0) ]],
                               constant float &timer [[ buffer(1) ]],
                               constant FragmentUniforms &fragementUniforms [[ buffer(BufferIndexFragmentUniforms) ]],
                               texture2d<float> normalTexture) {
    
    constexpr sampler s(filter::linear , address::repeat);
    
    float4 color;
    
    float2 uv = in.uv * 2.0;
    float waveStrength = 0.1;
    float2 rippleX = float2(uv.x + timer, uv.y);
    float2 rippleY = float2(-uv.x, uv.y) + timer;
    float2 ripple = ((normalTexture.sample(s, rippleX).rg * 2.0 - 1.0) + (normalTexture.sample(s, rippleY).rg * 2.0 - 1.0)) * waveStrength;
    
    
    float4 testColor = normalTexture.sample(s, ripple);
    color = mix(testColor, waterColor, 0.3);
    
    
    return color;
}


