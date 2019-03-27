//
//  Phong.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/23.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../Header/Common.h"
#import "Phong.h"


float3 diffuseLighting(float3 baseColor,
                       float3 position,
                       float3 normal,
                       constant Light *lights,
                       constant FragmentUniforms &fragmentUniforms)
{
    float3 diffuseColor = 0;
    float3 ambientColor = 0;
    float3 specularColor = 0;
    
    for (uint i = 0; i < fragmentUniforms.lightCount; i++ ) {
        Light light = lights[i];
        if (light.type == Sunlight)
        {
            float3 lightDirection = normalize(light.position);
            float intensity = dot(lightDirection, normal);
            // 将值变换到0-1的范围内
            float diffuseIntensity = saturate(intensity);
            
            diffuseColor += (light.color * diffuseIntensity) * baseColor;
        }
        else if (light.type == Pointlight)
        {
            float d = distance(light.position, position);
            float3 lightDirection = normalize(light.position - position);
            float attenuation = 1 / (light.attenuation.x + light.attenuation.y * d + light.attenuation.z * d * d);
            float diffuseIntensity = saturate(dot(lightDirection, normal));
            float3 color = baseColor * (light.color * diffuseIntensity);
            color *= attenuation;
            diffuseColor += color;
        }
        else if (light.type == Spotlight)
        {
            float d = distance(light.position, position);
            float3 lightDirection = normalize(light.position - position);
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
    
    float3 finalColor = diffuseColor + specularColor + ambientColor;
    
    return finalColor;
    
}


float3 phongLighting(float3 baseColor,
                     float3 position,
                     float3 normal,
                     constant Light *lights,
                     constant Material &material,
                     constant FragmentUniforms &fragmentUniforms) {
    
    float3 diffuseColor = 0;
    float3 ambientColor = 0;
    float3 specularColor = 0;
    
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
               
                float3 lightDirection = normalize(light.position);
                
                float materialShininess = material.shininess;
                float3 materialSpecularColor = material.specularColor;
                
                float3 reflection = reflect(lightDirection, normal);
                float3 cameraPosition = normalize(position - fragmentUniforms.cameraPosition);
                float specularIntensity = pow(saturate(dot(cameraPosition, reflection)), materialShininess);
                
                float3 reflectionColor = (light.specularColor * specularIntensity) * materialSpecularColor;
                
                specularColor += reflectionColor;
            }
        }
        else if (light.type == Pointlight)
        {
            float d = distance(light.position, position);
            float3 lightDirection = normalize(light.position - position);
            float attenuation = 1 / (light.attenuation.x + light.attenuation.y * d + light.attenuation.z * d * d);
            float diffuseIntensity = saturate(dot(lightDirection, normal));
            float3 color = baseColor * (light.color * diffuseIntensity);
            color *= attenuation;
            diffuseColor += color;
        }
        else if (light.type == Spotlight)
        {
            float d = distance(light.position, position);
            float3 lightDirection = normalize(light.position - position);
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
    
    float3 finalColor = diffuseColor + specularColor + ambientColor;
    
    return finalColor;
}


