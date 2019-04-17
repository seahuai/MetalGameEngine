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
    
    override init() { super.init() }
    
    init(_ light: Light) {
        super.init()
        self.type = light.type
        self.color = light.color
        self.specularColor = light.specularColor
        self.intensity = light.intensity
        self.attenuation = light.attenuation
        self.coneAngle = light.coneAngle
        self.coneDirection = light.coneDirection
        self.coneAttenuation = light.coneAttenuation
    }
    
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

extension Light: Equatable {
    public static func == (lhs: Light, rhs: Light) -> Bool {
        return lhs.id == rhs.id
    }
    
    private static var _id: uint = 0
    
    init(_ id: uint = 0) {
        self.init()
        self.id = Light._id
        Light._id += 1
    }
}
