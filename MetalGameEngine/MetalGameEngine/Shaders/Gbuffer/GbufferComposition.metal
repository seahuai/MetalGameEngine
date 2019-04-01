//
//  GbufferComposition.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/27.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../Header/Common.h"
#import "../Phong/Phong.h"

struct VertexOut {
    float4 position [[ position ]];
    float2 textureCoods;
};

vertex VertexOut vertex_composition(constant float2 *vertices [[ buffer(0) ]],
                                    constant float2 *textureCoods [[ buffer(1) ]],
                                    uint vertexId [[ vertex_id ]])
{
    VertexOut out;
    out.position = float4(vertices[vertexId], 0, 1);
    out.textureCoods = textureCoods[vertexId];
    return out;
}

fragment float4 fragment_composition(VertexOut in [[ stage_in ]],
                                     constant FragmentUniforms &fragmentUniforms [[ buffer(0) ]],
                                     constant Light *lights [[ buffer(1) ]],
                                     texture2d<float> colorTexture [[ texture(0) ]],
                                     texture2d<float> normalTexture [[ texture(1) ]],
                                     texture2d<float> positionTexture [[ texture(2) ]])
{
    constexpr sampler s(min_filter::linear, mag_filter::linear);
    
    float3 baseColor = colorTexture.sample(s, in.textureCoods).xyz;
    float3 normal = normalTexture.sample(s, in.textureCoods).xyz;
    float4 position = positionTexture.sample(s, in.textureCoods);
    
    float3 diffuseColor = diffuseLighting(baseColor,
                                          position.xyz,
                                          normal,
                                          lights,
                                          fragmentUniforms);
    
    if (position.a <= 0.001) {
        // in shadow
        diffuseColor *= 0.2;
    }
    
    return float4(diffuseColor, 1);
}




