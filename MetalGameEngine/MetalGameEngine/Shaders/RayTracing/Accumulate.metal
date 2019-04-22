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
                             texture2d<float, access::read_write> image [[texture(0)]])
{
    uint rayIndex = position.x + position.y * size.x;
    float4 outputColor = float4(rays[rayIndex].color, 1.0);
    if (frameIndex > 0)
    {
        float4 storedColor = image.read(position);
        float ratio =  float(frameIndex) / float(frameIndex + 1);
        outputColor = mix(outputColor, storedColor, ratio);
    }
    image.write(outputColor, position);
}
