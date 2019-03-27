//
//  Phong.h
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/23.
//  Copyright © 2019 张思槐. All rights reserved.
//

#ifndef Phong_h
#define Phong_h


float3 phongLighting(float3 baseColor,
                       float3 position,
                       float3 normal,
                       constant Light *lights,
                       constant Material &material,
                       constant FragmentUniforms &fragmentUniforms);

float3 diffuseLighting(float3 baseColor,
                       float3 position,
                       float3 normal,
                       constant Light *lights,
                       constant FragmentUniforms &fragmentUniforms);

#endif /* Phong_h */
