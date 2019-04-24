//
//  Accumulate.metal
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/22.
//  Copyright © 2019 张思槐. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "RayTracingStructure.h"

kernel void accumulateKernal(device Ray *rays [[ buffer(0) ]],
                             constant int &frameIndex [[ buffer(1) ]],
                             uint2 position [[ thread_position_in_grid ]],
                             uint2 size [[threads_per_grid ]],
                             texture2d<float> renderTarget [[ texture(0) ]],
                             texture2d<float, access::read_write> accumulateRenderTarget [[ texture(1) ]])
{
    if (position.x < size.x && position.y < size.y) {
        float3 color = renderTarget.read(position).xyz;
        
        if (frameIndex > 0)
        {
            float3 prevColor = accumulateRenderTarget.read(position).xyz;
            prevColor *= frameIndex;
            color += prevColor;
            color /= (frameIndex + 1);
        }
        
        accumulateRenderTarget.write(float4(color, 1.0), position);
    }
 
}
