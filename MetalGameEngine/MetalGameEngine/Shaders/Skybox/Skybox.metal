//
//  Skybox.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/25.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../Header/Common.h"


struct VertexIn {
    float4 position [[ attribute(0) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float3 textureCood;
    float clipDistance [[ clip_distance ]] [1];
};

struct FragmentIn {
    float4 position [[ position ]];
    float3 textureCood;
};

vertex VertexOut vertex_skybox(VertexIn in [[ stage_in ]],
                               constant Uniforms &uniforms [[ buffer(BufferIndexUniforms) ]])
{
    VertexOut out;
    out.position = (uniforms.projectionMatrix * uniforms.viewMatrix * in.position).xyww;
    out.textureCood = in.position.xyz;
    out.clipDistance[0] = dot(uniforms.clipPlane, (uniforms.modelMatrix * in.position));
    return out;
}

fragment float4 fragment_skybox(FragmentIn in [[ stage_in ]],
                                texturecube<float> cubeTexture [[ texture(0) ]])
{
    constexpr sampler s(filter::linear);
    float4 color = cubeTexture.sample(s, in.textureCood);
    return color;
}
