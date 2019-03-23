//
//  Main.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/20.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
#import "ShaderHeader.metal"

using namespace metal;

vertex VertexOut vertex_main(const VertexIn in [[ stage_in ]],
                             constant Uniforms &uniforms [[ buffer(BufferIndexUniforms) ]])
{
    VertexOut out;
    
    float4x4 mvp = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix;
    out.position = mvp * in.position;
    out.worldPosition = (uniforms.modelMatrix * in.position).xyz;
    out.worldNormal = uniforms.normalMatrix * in.normal;
    out.worldTangent = uniforms.normalMatrix * in.tangent;
    out.worldBitangent = uniforms.normalMatrix * in.bitangent;
    out.uv = in.uv;
    return out;
}
