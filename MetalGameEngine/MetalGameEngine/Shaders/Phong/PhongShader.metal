//
//  Phong.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/22.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
#import "../Header/ShaderHeader.hpp"

using namespace metal;

fragment float4 fragment_phong(VertexOut in [[ stage_in ]],
                               constant Light *lights [[ buffer(BufferIndexLights) ]],
                               constant FragmentUniforms &fragmentUniforms [[ buffer(BufferIndexFragmentUniforms) ]],
                               constant Material &material [[ buffer(BufferIndexMaterials) ]],
                               texture2d<float> baseColorTexture [[ texture(BaseColorTexture), function_constant(hasColorTexture) ]],
                               texture2d<float> normalTexture [[ texture(NormalTexture), function_constant(hasNormalTexture) ]],
                               depth2d<float> shadowTexture [[ texture(ShadowTexture) ]]) {
    
    constexpr sampler textureSampler(filter:: linear, address::repeat);
    
    float3 diffuseColor = 0;
    float3 ambientColor = 0;
    float3 specularColor = 0;
    
    float3 baseColor = 0;
    if (hasColorTexture) {
        baseColor = baseColorTexture.sample(textureSampler, in.uv * fragmentUniforms.tiling).rgb;
    }else {
        baseColor = material.baseColor;
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
    for (uint i = 0; i < fragmentUniforms.lightCount; i++ ) {
        Light light = lights[i];
        if (light.type == Sunlight)
        {
            float3 lightDirection = normalize(light.position);
            float intensity = dot(lightDirection, normal);
            // 将值变换到0-1的范围内
            float diffuseIntensity = saturate(intensity);
            
            diffuseColor += (light.color * diffuseIntensity) * baseColor;
            
            if (diffuseIntensity > 0) {
                float materialShininess = material.shininess;
                float3 materialSpecularColor = material.specularColor;
                
                float3 reflection = reflect(lightDirection, normal);
                float3 cameraPosition = normalize(in.worldPosition - fragmentUniforms.cameraPosition);
                float specularIntensity = pow(saturate(dot(cameraPosition, reflection)), materialShininess);
                
                specularColor += (light.specularColor * specularIntensity) * materialSpecularColor;
            }
        }
        else if (light.type == Pointlight)
        {
            float d = distance(light.position, in.worldPosition);
            float3 lightDirection = normalize(light.position - in.worldPosition);
            float attenuation = 1 / (light.attenuation.x + light.attenuation.y * d + light.attenuation.z * d * d);
            float diffuseIntensity = saturate(dot(lightDirection, normal));
            float3 color = baseColor * (light.color * diffuseIntensity);
            color *= attenuation;
            diffuseColor += color;
        }
        else if (light.type == Spotlight)
        {
            float d = distance(light.position, in.worldPosition);
            float3 lightDirection = normalize(light.position - in.worldPosition);
            float3 coneDirection = normalize(-light.coneDirection);
            float cosValue = dot(coneDirection, lightDirection);
            if (cosValue > cos(light.coneAngle)) {
                float attenuation = 1.0 / (light.attenuation.x + light.attenuation.y * d + light.attenuation.z * d * d);
                attenuation *= pow(cosValue, light.coneAttenuation);
                float diffuseIntensity = saturate(dot(lightDirection, normal));
                float3 color = light.color * baseColor * diffuseIntensity;
                color *= attenuation;
                diffuseColor += color;
            }
        }
        else if (light.type == Ambientlight)
        {
            ambientColor += light.color * light.intensity;
        }
    }
    
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
    
    float3 finalColor = diffuseColor + specularColor + ambientColor;
    
    if (inShadow) {
        finalColor *= 0.5;
    }
    
    return float4(finalColor, 1);
}
