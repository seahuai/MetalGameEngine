//
//  NSColorExtension.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/14.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

extension NSColor {
    
    var float3Value: float3 {
        let float4Value = self.float4Value
        return [float4Value.x, float4Value.y, float4Value.z]
    }
    
    var float4Value: float4 {
        
        guard let colorSpace = NSColorSpace(cgColorSpace: CGColorSpaceCreateDeviceRGB()),
            let rgbColor = self.usingColorSpace(colorSpace) else {
                return float4(repeating: 0)
        }
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 1
        
        rgbColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return [Float(r), Float(g), Float(b), Float(a)]
    }
}


