//
//  RayTracingViewController.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/16.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class RayTracingViewController: NormalMetalViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = Scene()
        
        var light = Light()
        light.type = Sunlight
        light.position = float3(0.0, 2, 0.0)
        light.forward = float3(0.0, -1.0, 0.0)
        light.right = float3(0.25, 0.0, 0.0)
        light.up = float3(0.0, 0.0, 0.25)
        light.color = float3(4.0)
        
        scene.lights.append(light)
        
        let plane = RayTracingModel(name: "plane")!
        scene.add(node: plane)
        
        let train = RayTracingModel(name: "treefir")!
        scene.add(node: train)
        
        self.renderer = RayTracingTestRenderer(metalView: self.mtkView, scene: scene)
    }
    
}
