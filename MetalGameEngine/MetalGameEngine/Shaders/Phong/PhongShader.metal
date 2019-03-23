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



fragment float4 fragment_phong(VertexOut in [[ stage_in ]]) {
    return float4(1, 0, 0, 1);
}
