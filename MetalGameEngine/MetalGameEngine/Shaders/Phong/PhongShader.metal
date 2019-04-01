//
//  Phong.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/22.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
#import "../Header/ShaderHeader.hpp"
#import "Phong.h"

using namespace metal;

fragment float4 fragment_phong(VertexOut in [[ stage_in ]],
                               constant Light *lights [[ buffer(BufferIndexLights) ]],
                               constant FragmentUniforms &fragmentUniforms [[ buffer(BufferIndexFragmentUniforms) ]],
                               constant Material &material [[ buffer(BufferIndexMaterials) ]],
                               texture2d<float> baseColorTexture [[ texture(BaseColorTexture), function_constant(hasColorTexture) ]],
                               texture2d<float> normalTexture [[ texture(NormalTexture), function_constant(hasNormalTexture) ]],
                               depth2d<float> shadowTexture [[ texture(ShadowTexture) ]]) {
    
    constexpr sampler textureSampler(filter:: linear, address::repeat);
    
    float4 baseColor;
    if (hasColorTexture) {
        baseColor = baseColorTexture.sample(textureSampler, in.uv * fragmentUniforms.tiling);
    }else {
        baseColor = float4(material.baseColor, 1);
    }
    
    if (baseColor.a <= 0.001) {
        discard_fragment();
    }
    
    float3 normal = 0;
    if (hasNormalTexture) {
        normal = normalTexture.sample(textureSampler, in.uv * fragmentUniforms.tiling).rgb;
        normal = normal * 2 - 1;
        normal = float3x3(in.worldTangent, in.worldBitangent, in.worldNormal) * normal;
    }else {
        normal = in.worldNormal;
    }
    
    normal = normalize(normal);
    
    float3 finalColor = phongLighting(baseColor.rgb,
                                        in.worldPosition,
                                        normal,
                                        lights,
                                        material,
                                        fragmentUniforms);
    
    // 计算是否处于阴影中
    bool inShadow = false;
    constexpr sampler s(coord::normalized, filter::linear,
                        address::clamp_to_edge, compare_func:: less);
    float2 xy = in.shadowPosition.xy;
    xy = xy * 0.5 + 0.5;
    xy.y = 1 - xy.y;
    float shadowSample = shadowTexture.sample(s, xy);
    float currentSample = in.shadowPosition.z / in.shadowPosition.w;
    
    if (currentSample > shadowSample ) {
        inShadow = true;
    }
    
    if (inShadow) {
        finalColor *= 0.5;
    }
    
    return float4(finalColor, 1);
}
