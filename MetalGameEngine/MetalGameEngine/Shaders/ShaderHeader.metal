//
//  ModelHeader.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/22.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
#import "Common.h"

using namespace metal;

constant bool hasColorTexture [[ function_constant(0) ]];
constant bool hasNormalTexture [[ function_constant(1) ]];
constant bool hasRoughnessTexture [[ function_constant(2) ]];
constant bool hasMetallicTexture [[ function_constant(3) ]];
constant bool hasAOTexture [[ function_constant(4) ]];

struct VertexIn {
    float4 position [[ attribute(Position) ]];
    float3 normal [[ attribute(Normal) ]];
    float2 uv [[ attribute(UV) ]];
    float3 tangent [[ attribute(Tangent) ]];
    float3 bitangent [[ attribute(Bitangent) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float3 worldPosition;
    float3 worldNormal;
    float2 uv;
    float3 worldTangent;
    float3 worldBitangent;
};

