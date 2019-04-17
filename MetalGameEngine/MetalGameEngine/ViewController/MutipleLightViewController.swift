//
//  MutipleLightViewController.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/26.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class MutipleLightViewController: NormalMetalViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let plane = Model(name: "plane")!
        plane.scale = [8, 8, 8]
        plane.tiling = 16
        
        let train = Model(name: "train")!
        train.position = [0, 0, 0]
        
        scene.add(node: plane)
        scene.add(node: train)
        
        let camera = Camera()
        camera.position = [0, 2, -10]
        camera.rotation = [-0.5, 0, 0]
        scene.cameras.append(camera)
        
        scene.lights.append(sunLight)
        
        let skybox = Skybox(textureName: "redSky")
        scene.skybox = skybox
        
        setupAddButton()
        
        self.renderer = DeferredRenderer(metalView: self.mtkView, scene: scene)
    }
    
    func setupAddButton() {
        let button = NSButton(title: "添加随机光源", target: self, action: #selector(randomAddPointLight))
        button.sizeToFit()
        self.view.addSubview(button)
    }
    
    override func scrollWheel(with event: NSEvent) {
        let delta = event.deltaY
        scene.sceneZooming(delta)
    }
    
    override func gesturePan(_ translation: float2) {
        scene.sceneRotate(translation)
    }
}

extension MutipleLightViewController {
    @objc func randomAddPointLight() {
        let min: float3 = [-5, 0.3, -5]
        let max: float3 = [5, 2.0, 5]
        
        let colors: [float3] = [
            float3(1, 0, 0),
            float3(1, 1, 0),
            float3(1, 1, 1),
            float3(0, 1, 0),
            float3(0, 1, 1),
            float3(0, 0, 1),
            float3(0, 1, 1),
            float3(1, 0, 1) ]
        
        var newMin: float3 = [min.x*100, min.y*100, min.z*100]
        var newMax: float3 = [max.x*100, max.y*100, max.z*100]
        
        let x = Float(random(range: Int(newMin.x)...Int(newMax.x))) * 0.01
        let y = Float(random(range: Int(newMin.y)...Int(newMax.y))) * 0.01
        let z = Float(random(range: Int(newMin.z)...Int(newMax.z))) * 0.01
        
        var light = Light()
        light.position = [x, y, z]
        light.color = colors[random(range: 0...colors.count)]
        light.intensity = 0.6
        light.attenuation = float3(1.5, 1, 1)
        light.type = Pointlight
        scene.lights.append(light)
    }
}
