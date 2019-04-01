//
//  Gbuffer.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/27.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../Header/ShaderHeader.hpp"

struct GbufferOut {
    float4 baseColor [[ color(0) ]];
    float4 normal [[ color(1) ]];
    float4 position [[ color(2) ]];
};

fragment GbufferOut fragment_gbuffer(VertexOut in [[ stage_in ]],
                                     constant Material &material [[ buffer(BufferIndexMaterials) ]],
                                     constant FragmentUniforms &fragmentUniforms [[ buffer(BufferIndexFragmentUniforms) ]],
                                     texture2d<float> baseColorTexture [[ texture(BaseColorTexture), function_constant(hasColorTexture) ]],
                                     texture2d<float> normalTexture [[ texture(NormalTexture), function_constant(hasNormalTexture) ]],
                                     depth2d<float> depthTextrue [[ texture(DepthTexture) ]])
{
    GbufferOut out;
    
    constexpr sampler s(filter::linear, address::repeat);
    
    float3 baseColor;
    if (hasColorTexture) {
        baseColor = baseColorTexture.sample(s, in.uv * fragmentUniforms.tiling).rgb;
    } else {
        baseColor = material.baseColor;
    }
    out.baseColor = float4(baseColor, 1);
    
    if (hasNormalTexture) {
        out.normal = normalTexture.sample(s, in.uv * fragmentUniforms.tiling);
    } else {
        out.normal = float4(normalize(in.worldNormal), 1);
    }
    
    out.position = float4(in.worldPosition, 1);
    
    // 计算是否处于阴影中
    constexpr sampler shadowSampler(coord::normalized, filter::linear,
                        address::clamp_to_edge, compare_func:: less);
    float2 xy = in.shadowPosition.xy;
    xy = xy * 0.5 + 0.5;
    xy.y = 1 - xy.y;
    float shadowSample = depthTextrue.sample(shadowSampler, xy);
    float currentSample = in.shadowPosition.z / in.shadowPosition.w;
    
    if (currentSample > shadowSample ) {
        out.baseColor.a = 0;
    }
    
    return out;
}


