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
    
    lazy var cube = Model(name: "cube")!
    
    lazy var chest = Model(name: "chest")!
    
    lazy var plane = Model(name: "plane", fragmentFunctionName: "fragment_phong")!
    
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
        
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        scene = Scene()
        renderer = SceneRenderer(metalView: self.mtkView, scene: self.scene)
        
        plane.scale = [8, 8, 8]
        plane.position = [0, 0, 0]
//        plane.add(cube)
//        plane.add(chest)
        
        cube.position = [0, -cube.size.y / 2, 0]
        chest.position = [0, 0, 0]
        
        scene.add(node: plane)
        scene.add(node: cube)
        scene.add(node: chest)
        
        let camera = Camara()
        camera.position = [0, 0, -6]
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
