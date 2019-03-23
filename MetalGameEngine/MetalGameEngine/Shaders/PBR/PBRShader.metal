//
//  PBR.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/22.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
#import "../Header/ShaderHeader.hpp"
#import "PBR.h"

using namespace metal;

fragment float4 fragment_PBR(VertexOut in [[ stage_in ]],
                             constant Light *lights [[ buffer(BufferIndexLights) ]],
                             constant Material &material [[ buffer(BufferIndexMaterials) ]],
                             constant FragmentUniforms &fragmentUniforms [[ buffer(BufferIndexFragmentUniforms) ]],
                             texture2d<float> baseColorTexture [[ texture(BaseColorTexture), function_constant(hasColorTexture) ]],
                             texture2d<float> normalTexture [[ texture(NormalTexture), function_constant(hasNormalTexture) ]],
                             texture2d<float> roughnessTexture [[ texture(RoughnessTexture), function_constant(hasRoughnessTexture) ]],
                             texture2d<float> metallicTexture [[ texture(MetallicTexture),  function_constant(hasMetallicTexture) ]],
                             texture2d<float> aoTexture [[ texture(AOTexture), function_constant(hasAOTexture) ]])
{
    constexpr sampler textureSampler(filter::linear, address::repeat);
    
    float3 baseColor;
    if (hasColorTexture) {
        baseColor = baseColorTexture.sample(textureSampler,
                                            in.uv * fragmentUniforms.tiling).rgb;
    } else {
        baseColor = material.baseColor;
    }
    
    float metallic;
    if (hasMetallicTexture) {
        metallic = metallicTexture.sample(textureSampler, in.uv).r;
    } else {
        metallic = material.metallic;
    }
    
    float roughness;
    if (hasRoughnessTexture) {
        roughness = roughnessTexture.sample(textureSampler, in.uv).r;
    } else {
        roughness = material.roughness;
    }
    // extract ambient occlusion
    float ambientOcclusion;
    if (hasAOTexture) {
        ambientOcclusion = aoTexture.sample(textureSampler, in.uv).r;
    } else {
        ambientOcclusion = 1.0;
    }
    
    // normal map
    float3 normal;
    if (hasNormalTexture) {
        float3 normalValue = normalTexture.sample(textureSampler, in.uv * fragmentUniforms.tiling).xyz * 2.0 - 1.0;
        normal = in.worldNormal * normalValue.z
        + in.worldTangent * normalValue.x
        + in.worldBitangent * normalValue.y;
    } else {
        normal = in.worldNormal;
    }
    normal = normalize(normal);
    
    float3 viewDirection = normalize(fragmentUniforms.cameraPosition - in.worldPosition);
    
    Light light = lights[0];
    float3 lightDirection = normalize(light.position);
    lightDirection = light.position;
    
    // all the necessary components are in place
    Lighting lighting;
    lighting.lightDirection = lightDirection;
    lighting.viewDirection = viewDirection;
    lighting.baseColor = baseColor;
    lighting.normal = normal;
    lighting.metallic = metallic;
    lighting.roughness = roughness;
    lighting.ambientOcclusion = ambientOcclusion;
    lighting.lightColor = light.color;
    
    float3 specularOutput = render(lighting);
    
    // compute Lambertian diffuse
    float nDotl = max(0.001, saturate(dot(lighting.normal, lighting.lightDirection)));
    float3 diffuseColor = light.color * baseColor * nDotl * ambientOcclusion;
    diffuseColor *= 1.0 - metallic;
    
    float4 finalColor = float4(specularOutput + diffuseColor, 1.0);
    
    return finalColor;
}


