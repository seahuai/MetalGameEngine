//
//  PhongViewController.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/23.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class PhongViewController: NormalMetalViewController {
    
    let scene = Scene()

    var models: [Model] = []
    
    lazy var sunLight: Light = {
        var light = Light()
        light.position = [0, 4, -1]
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
    
    lazy var pointLight: Light = {
        var light = Light()
        light.position = [0, 1, 0.5]
        light.color = [1, 0, 0]
        light.attenuation = [1, 2, 3]
        light.type = Pointlight
        return light
    }()
    
    lazy var spotLight: Light = {
        var light = Light()
        light.position = [-0.5, 0.8, -1]
        light.color = [1, 1, 0]
        light.coneAngle = radians(fromDegrees: 30)
        light.coneDirection = [0, 0, 1]
        light.attenuation = [1, 2, 3]
        light.type = Spotlight
        return light
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.renderer = PhongRenderer(metalView: self.mtkView, scene: self.scene)
        
        self.mtkView.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        let plane = Model(name: "plane")!
        plane.scale = [8, 8, 8]
        plane.tiling = 16
        
        let train = Model(name: "train")!
        train.position = [0, 0, 0]
        
        scene.add(node: plane)
        scene.add(node: train)
        
        let camera = Camera()
        camera.position = [0, 1, -3]
        scene.cameras.append(camera)
        
        scene.lights.append(ambientLight)
        scene.lights.append(sunLight)
        scene.lights.append(pointLight)
        scene.lights.append(spotLight)
    }
    
    override func scrollWheel(with event: NSEvent) {
        let delta = event.deltaY
        scene.sceneZooming(delta)
    }
    
    override func gesturePan(_ translation: float2) {
        scene.sceneHorizontalRotate(translation)
    }
}
