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
        
        self.renderer = RayTracingTestRenderer(metalView: self.mtkView, scene: scene)
    }
    
}
