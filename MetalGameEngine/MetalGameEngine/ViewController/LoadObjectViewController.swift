//
//  LoadObjectViewController.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/20.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class LoadObjectViewController: NormalMetalViewController {
    
    var renderer: SceneRenderer!
    var scene: Scene!
    
    lazy var cube: Model = Model(name: "cube")!
    
    lazy var amibientLight: Light = {
        var light = Light()
        light.position = [0, 1, 0]
        light.color = [1, 1, 1]
        light.specularColor = [0.6, 0.6, 0.6]
        light.intensity = 0.5
        light.attenuation = float3(1, 0, 0)
        light.type = Ambientlight
        return light
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene = Scene()
        renderer = SceneRenderer(metalView: self.mtkView, scene: self.scene)
        
        cube.position = [0, 0, 0]
        scene.add(node: cube)
        
        let camera = Camara()
        camera.position = [0, 0, -3]
        scene.cameras.append(camera)
        
        scene.lights.append(amibientLight)
    }
    
    override func scrollWheel(with event: NSEvent) {
        let delta = event.deltaY
        scene.sceneZooming(delta)
    }
    
    override func gesturePan(_ translation: float2) {
        scene.sceneRotate(translation)
    }
}
