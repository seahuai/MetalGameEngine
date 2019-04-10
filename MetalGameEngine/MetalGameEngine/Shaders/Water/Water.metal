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
                               texture2d<float> normalTexture [[ texture(0) ]],
                               texture2d<float> reflectionTexture [[ texture(1) ]],
                               texture2d<float> refractionTexture [[ texture(2) ]])
{
    
    constexpr sampler s(filter::linear , address::repeat);
    
    float4 color;
    
    float width = reflectionTexture.get_width();
    float height = reflectionTexture.get_height();
    float x = in.position.x / width;
    float y = in.position.y / height;
    float2 reflectionCood = float2(x, 1 - y);
    float2 refractionCood = float2(x, y);
    
    float tiling = 1.0;
    float2 uv = in.uv * tiling;
    float waveStrength = 0.1;
    float2 rippleX = float2(uv.x + timer, uv.y);
    float2 rippleY = float2(-uv.x, uv.y) + timer;
    float2 ripple = ((normalTexture.sample(s, rippleX).rg * 2.0 - 1.0) + (normalTexture.sample(s, rippleY).rg * 2.0 - 1.0)) * waveStrength;
    
    reflectionCood += ripple;
    refractionCood += ripple;
    
    float3 toCamera = normalize(fragementUniforms.cameraPosition - in.worldPosition);
    float mixRatio = dot(toCamera, float3(0, 1, 0));
    
    float4 reflection = reflectionTexture.sample(s, reflectionCood);
    float4 refraction = refractionTexture.sample(s, refractionCood);
    
    color = mix(reflection, refraction, mixRatio);
    
    color = mix(color, waterColor, 0.3);
    
    return color;
}


