//
//  InstanceViewController.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/4/1.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class InstanceViewController: NormalMetalViewController {

    let scene = Scene()
    
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
        
        let camera = Camara()
        camera.position = [0, 1, -5]
        scene.cameras.append(camera)
        
        let plane = Model(name: "large-plane")!
        plane.tiling = 16
        scene.add(node: plane)
    
        
        let tree = Model(name: "tree")!
        tree.instanceCount = 10
        for i in 0..<tree.instanceCount {
            var transform = Transform()
            transform.position.x = .random(in: -5...5)
            transform.position.z = .random(in: 0...8)
            transform.rotation.y = .random(in: -Float.pi..<Float.pi)
            tree.update(transform: transform, at: i)
        }
        scene.add(node: tree)
        
        let skybox = Skybox()
        scene.skybox = skybox

        scene.lights.append(sunLight)
        scene.lights.append(ambientLight)
        
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
