//
//  DebugLight.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/3.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../Header/Common.h"

struct VertexOut {
    float4 position [[ position ]];
    float pointSize [[ point_size ]];
};

vertex VertexOut debugVertex_light(constant float3 *vertices [[ buffer(0) ]],
                                   constant Uniforms &uniforms [[ buffer(1) ]],
                                   uint id [[vertex_id]])
{
    VertexOut out;
    matrix_float4x4 mvp = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix;
    out.position = mvp * float4(vertices[id], 1);
    out.pointSize = 20.0;
    return out;
}

fragment float4 debugFragment_light(float2 point [[ point_coord ]],
                                    constant float3 &color [[ buffer(1) ]]) {
    return float4(color ,1);
}
