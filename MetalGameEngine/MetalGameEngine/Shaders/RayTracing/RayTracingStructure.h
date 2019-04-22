//
//  RayTracingStructure.h
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/22.
//  Copyright © 2019 张思槐. All rights reserved.
//

#ifndef RayTracingStructure_h
#define RayTracingStructure_h

#import <simd/simd.h>

struct Ray {
    packed_float3 origin;
    float minDistance;
    packed_float3 direction;
    float maxDistance;
    float3 color;
};

struct Intersection {
    float distance;
    uint primitiveIndex;
    float2 coordinates;
};

#endif /* RayTracingStructure_h */
