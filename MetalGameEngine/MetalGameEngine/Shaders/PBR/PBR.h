//
//  PBR.h
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/23.
//  Copyright © 2019 张思槐. All rights reserved.
//

#ifndef PBR_h
#define PBR_h

#import <simd/simd.h>

typedef struct Lighting {
    float3 lightDirection;
    float3 viewDirection;
    float3 baseColor;
    float3 normal;
    float metallic;
    float roughness;
    float ambientOcclusion;
    float3 lightColor;
} Lighting;

float3 render(Lighting lighting);


#endif /* PBR_h */
