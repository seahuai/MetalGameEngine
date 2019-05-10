//
//  Shadow.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/23.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


#import "../Header/Common.h"

struct VertexIn {
    float4 position [[ attribute(Position) ]];
};

vertex float4 vertex_depth(VertexIn in [[ stage_in ]],
                           constant Uniforms &uniforms [[ buffer(BufferIndexUniforms) ]],
                           constant InstanceUniforms *instancesUniforms [[ buffer(BufferIndexInstanceUniforms) ]],
                           uint instanceId [[ instance_id ]])
{
    float4x4 modelMatrix = uniforms.worldTransformModelMatrix * instancesUniforms[instanceId].modelMatrix;
    float4x4 mvp = uniforms.projectionMatrix * uniforms.viewMatrix * modelMatrix;
    float4 position = mvp * in.position;
    return position;
}
