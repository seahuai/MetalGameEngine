//
//  WaterViewController.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/9.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class WaterViewController: NormalMetalViewController {
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
        
        let skybox = Skybox(textureName: "redSky")
        scene.skybox = skybox
        
        let plane = Model(name: "large-plane")!
        plane.tiling = 16
        
        scene.add(node: plane)
        
        let camera = Camera()
        camera.position = [0, 0, -4]
        camera.rotation = [-0.5, -0.5, 0]
        scene.cameras.append(camera)
        
        scene.lights.append(ambientLight)
        scene.lights.append(sunLight)
        
        let water = Water(size: [5, 5])
        water.position = [0, 0.2, 0]
        scene.add(node: water)
        
        self.renderer = PhongRenderer(metalView: self.mtkView, scene: scene)
    }
    
    override func scrollWheel(with event: NSEvent) {
        let delta = event.deltaY
        scene.sceneZooming(delta)
    }
    
    override func gesturePan(_ translation: float2) {
        scene.sceneRotate(translation)
    }
    
    
}
