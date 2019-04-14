//
//  LightNode.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/14.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class LightNode: Node {
    
    var type: LightType = unused
    var color: float3 = [1, 1, 1]
    var specularColor: float3 = [1, 1, 1]
    var intensity: Float = 0.7
    var attenuation: float3 = [2, 2, 2]
    var coneAngle: Float = radians(fromDegrees: 45)
    var coneDirection: float3 = [0, 0, 0]
    var coneAttenuation: Float = 12
    
    var light: Light {
        var light = Light()
        light.type = type
        light.color = color
        light.specularColor = specularColor
        light.intensity = intensity
        light.attenuation = attenuation
        light.coneAngle = coneAngle
        light.coneDirection = coneDirection
        light.coneAttenuation = coneAttenuation
        light.position = self.position
        return light
    }
    
}

//extension LightNode
