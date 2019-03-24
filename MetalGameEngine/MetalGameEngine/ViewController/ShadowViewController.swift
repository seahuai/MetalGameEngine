//
//  ShadowViewController.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/23.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class ShadowViewController: NormalMetalViewController {
    
    let scene = Scene()
    
    var models: [Model] = []
    
    lazy var sunLight: Light = {
        var light = Light()
        light.position = [0, 4, -5]
        light.color = [1, 1, 0.87]
        light.specularColor = [1, 1, 1]
        light.type = Sunlight
        return light
    }()
    
    lazy var ambientLight: Light = {
        var light = Light()
        light.color = [1, 0.9, 0.8]
        light.intensity = 0.1
        light.type = Ambientlight
        return light
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mtkView.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        let plane = Model(name: "plane")!
        plane.scale = [8, 8, 8]
        plane.tiling = 16
        
        let train = Model(name: "train")!
        train.position = [0, 0, -1]
        
        let tree = Model(name: "treefir")!
        tree.position = [0, 0, 1]
        
        scene.add(node: plane)
        scene.add(node: train)
        scene.add(node: tree)
        
        let camera = Camara()
        camera.position = [0, 0, -4]
        camera.rotation = [-0.5, -0.5, 0]
        scene.cameras.append(camera)
        
        scene.lights.append(ambientLight)
        scene.lights.append(sunLight)
        
        self.renderer = ShadowRenderer(metalView: self.mtkView, scene: scene, light: sunLight)
    }
    
    override func scrollWheel(with event: NSEvent) {
        let delta = event.deltaY
        scene.sceneZooming(delta)
    }
    
    override func gesturePan(_ translation: float2) {
        scene.sceneRotate(translation)
    }
}
