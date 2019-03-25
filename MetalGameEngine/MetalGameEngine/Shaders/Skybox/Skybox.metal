//
//  Skybox.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/25.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexIn {
    float4 position [[ attribute(0) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float3 textureCood;
};

vertex VertexOut vertex_skybox(VertexIn in [[ stage_in ]],
                               constant float4x4 &matrix [[ buffer(1) ]])
{
    VertexOut out;
    out.position = (matrix * in.position).xyww;
    out.textureCood = in.position.xyz;
    return out;
}

fragment float4 fragment_skybox(VertexOut in [[ stage_in ]],
                                texturecube<float> cubeTexture [[ texture(0) ]])
{
    constexpr sampler s(filter::linear);
    float4 color = cubeTexture.sample(s, in.textureCood);
    return color;
}
