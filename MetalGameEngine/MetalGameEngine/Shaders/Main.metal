//
//  Main.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/20.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
#import "./Header/ShaderHeader.hpp"

using namespace metal;

vertex VertexOut vertex_main(const VertexIn in [[ stage_in ]],
                             constant Uniforms &uniforms [[ buffer(BufferIndexUniforms) ]],
                             constant InstanceUniforms *instancesUniforms [[ buffer(BufferIndexInstanceUniforms) ]],
                             uint instanceId [[ instance_id ]])
{
    VertexOut out;
    
    InstanceUniforms instanceUniforms = instancesUniforms[instanceId];
    
    float4x4 modelMatrix = uniforms.worldTransformModelMatrix * instanceUniforms.modelMatrix;
    float4x4 mvp = uniforms.projectionMatrix * uniforms.viewMatrix * modelMatrix;
    out.position = mvp * in.position;
    out.worldPosition = (modelMatrix * in.position).xyz;
    out.worldNormal = instanceUniforms.normalMatrix * in.normal;
    out.worldTangent = instanceUniforms.normalMatrix * in.tangent;
    out.worldBitangent = instanceUniforms.normalMatrix * in.bitangent;
    out.uv = in.uv;
    out.shadowPosition = uniforms.shadowMatrix * modelMatrix * in.position;
    out.clipDistance[0] = dot(uniforms.clipPlane, (instanceUniforms.modelMatrix * in.position));
    return out;
}
