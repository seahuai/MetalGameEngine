//
//  RayTracing.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/18.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#import "RayTracingStructure.h"
#import "../Header/Common.h"

// MARK: - Method Define
template<typename T>
inline T interpolateVertexAttribute(device T *attributes, Intersection intersection);

inline void sampleAreaLight(constant Light &light, float2 randomCood, float3 position, thread float3 &lightDirection, thread float3 &lightColor, thread float &lightDistance);

inline float3 sampleCosineWeightedHemisphere(float2 u);

inline float3 alignHemisphereWithNormal(float3 sample, float3 normal);

// MARK: - Shdaer
kernel void generateRays(texture2d<float, access::read_write> renderTarget [[ texture(0) ]],
                         device Ray *rays [[ buffer(0) ]],
                         constant float2 *randomCoods [[ buffer(1) ]],
                         constant float3 &cameraPosition [[ buffer(2) ]],
                         uint2 position [[ thread_position_in_grid ]],
                         uint2 size [[threads_per_grid ]])
{
    // ray index
    uint index = position.x + position.y * size.x;
    
    // antialiasing
    float2 pixel = (float2)position;
    float2 r = randomCoods[(position.y % 16) * 16 + (position.x % 16)];
    pixel += r;
    
    // convert position to (-1, 1)
    float2 uv = (float2)pixel / (float2)size;
    uv = uv * 2.0 - 1.0;
    
    // camera origin
    float3 origin = cameraPosition;
    float aspect = float(size.y) / float(size.x);
    float3 direction = float3(uv.x, uv.y * aspect, 1.0);
    direction = normalize(direction);

    
    rays[index].origin = origin;
    rays[index].direction = direction;
    rays[index].minDistance = 0.0;
    rays[index].maxDistance = INFINITY;
    rays[index].color = float3(1);
    
    // 将图像背景设置为黑色
    renderTarget.write(float4(0), position);
}

kernel void handleIntersecitons(texture2d<float, access::write> renderTarget [[ texture(0) ]],
                                device Intersection *intersections [[ buffer(0) ]],
                                device Ray *rays [[ buffer(1) ]],
                                device float3 *normals [[ buffer(2) ]],
                                device float3 *colors [[ buffer(3) ]],
                                device Ray *shadowRays [[ buffer(4) ]],
                                constant Light &light [[ buffer(5) ]],
                                constant bool &hasLight [[ buffer(6) ]],
                                constant float2 *randomCoods [[ buffer(7) ]],
                                uint2 position [[ thread_position_in_grid ]],
                                uint2 size [[ threads_per_grid ]])
{
    uint index = position.x + position.y * size.x;
    device Intersection &intersection = intersections[index];
    device Ray &ray = rays[index];
    device Ray &shadowRay = shadowRays[index];
    float3 color = ray.color;
    
    if (ray.maxDistance >= 0.0f && intersection.distance >= 0.0f) {
        color *= interpolateVertexAttribute(colors, intersection);
        float2 randomCood = randomCoods[(position.y % 16) * 16 + (position.x % 16)];
        
        // 创建阴影射线
        // 1. 求出当前射线的交点位置，作为阴影射线的起点
        float3 intersectionPoint = ray.origin + ray.direction * intersection.distance;
        
        // 2. 计算法向量
        float3 normal = interpolateVertexAttribute(normals, intersection);
        normal = normalize(normal);
        
        // 3. 计算光照相关内容
        float3 lightColor;
        float3 lightDirection;
        float lightDistance;
        sampleAreaLight(light, randomCood, intersectionPoint, lightDirection, lightColor, lightDistance);
        
        // 4. 光照的颜色
        float intensity = saturate(dot(normalize(lightDirection), normal));
        lightColor *= intensity;
        
        // 5. 设置 shadowRay
        shadowRay.origin = intersectionPoint + normal * 1e-3f; // 稍微偏移
        shadowRay.direction = lightDirection;
        shadowRay.maxDistance = lightDistance - 1e-3f;
        shadowRay.color = lightColor * color;
        
        // 散射
        float3 sampleDirection = sampleCosineWeightedHemisphere(randomCood);
        sampleDirection = alignHemisphereWithNormal(sampleDirection, normal);
        ray.origin = intersectionPoint + normal * 1e-3f;
        ray.direction = sampleDirection;
        ray.color = color;
    } else {
        ray.maxDistance = -1;
        shadowRay.maxDistance = -1;
    }
}

// 主要的着色过程
kernel void shadowKernal(texture2d<float, access::read_write> renderTarget [[ texture(0) ]],
                         device Ray *shadowRays [[ buffer(0) ]],
                         device float *intersections [[ buffer(1) ]],
                         uint2 position [[ thread_position_in_grid ]],
                         uint2 size [[ threads_per_grid ]])
{
    if (position.x < size.x && position.y < size.y) {
        uint index = position.y * size.x + position.x;
        device Ray &shadowRay = shadowRays[index];
        float intersectionDistance = intersections[index];
        // 射线能够抵达光源，说明该像素的没有被遮挡，所以需要着色
        if (shadowRay.maxDistance >= 0.0 && intersectionDistance < 0.0) {
            float3 color = shadowRay.color;
            color += renderTarget.read(position).xyz;
            renderTarget.write(float4(color, 1.0), position);
        }
    }
}

// MARK: - Method

// Interpolates vertex attribute of an arbitrary type across the surface of a triangle
// given the barycentric coordinates and triangle index in an intersection struct
template<typename T>
inline T interpolateVertexAttribute(device T *attributes, Intersection intersection) {
    float3 uvw;
    uvw.xy = intersection.coordinates;
    uvw.z = 1.0 - uvw.x - uvw.y;
    unsigned int triangleIndex = intersection.primitiveIndex;
    T T0 = attributes[triangleIndex * 3 + 0];
    T T1 = attributes[triangleIndex * 3 + 1];
    T T2 = attributes[triangleIndex * 3 + 2];
    return uvw.x * T0 + uvw.y * T1 + uvw.z * T2;
}

// Maps two uniformly random numbers to the surface of a two-dimensional area light
// source and returns the direction to this point, the amount of light which travels
// between the intersection point and the sample point on the light source, as well
// as the distance between these two points.
inline void sampleAreaLight(constant Light & light,
                            float2 randomCood,
                            float3 position,
                            thread float3 &lightDirection,
                            thread float3 &lightColor,
                            thread float &lightDistance)
{
    // Map to -1..1
    randomCood = randomCood * 2.0f - 1.0f;
    
    // Transform into light's coordinate system
    float3 samplePosition = light.position + light.right * randomCood.x + light.up * randomCood.y;
    
    // Compute vector from sample point on light source to intersection point
    lightDirection = samplePosition - position;
    
    lightDistance = length(lightDirection);
    
    float inverseLightDistance = 1.0f / max(lightDistance, 1e-3f);
    
    // Normalize the light direction
    lightDirection *= inverseLightDistance;
    
    // Start with the light's color
    lightColor = light.color;
    
    // Light falls off with the inverse square of the distance to the intersection point
    lightColor *= (inverseLightDistance * inverseLightDistance);
    
    // Light also falls off with the cosine of angle between the intersection point and
    // the light source
    lightColor *= saturate(dot(-lightDirection, light.forward));
}

// Uses the inversion method to map two uniformly random numbers to a three dimensional
// unit hemisphere where the probability of a given sample is proportional to the cosine
// of the angle between the sample direction and the "up" direction (0, 1, 0)
inline float3 sampleCosineWeightedHemisphere(float2 u) {
    float phi = 2.0f * M_PI_F * u.x;
    
    float cos_phi;
    float sin_phi = sincos(phi, cos_phi);
    
    float cos_theta = sqrt(u.y);
    float sin_theta = sqrt(1.0f - cos_theta * cos_theta);
    
    return float3(sin_theta * cos_phi, cos_theta, sin_theta * sin_phi);
}

// Aligns a direction on the unit hemisphere such that the hemisphere's "up" direction
// (0, 1, 0) maps to the given surface normal direction
inline float3 alignHemisphereWithNormal(float3 sample, float3 normal) {
    // Set the "up" vector to the normal
    float3 up = normal;
    
    // Find an arbitrary direction perpendicular to the normal. This will become the
    // "right" vector.
    float3 right = normalize(cross(normal, float3(0.0072f, 1.0f, 0.0034f)));
    
    // Find a third vector perpendicular to the previous two. This will be the
    // "forward" vector.
    float3 forward = cross(right, up);
    
    // Map the direction on the unit hemisphere to the coordinate system aligned
    // with the normal.
    return sample.x * right + sample.y * up + sample.z * forward;
}

