//
//  TerrainViewController.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/29.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class TerrainViewController: NormalMetalViewController {
    
    let scene = Scene()
    
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
        
        self.mtkView.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        let camera = Camera()
        camera.position = [0, 1, -5]
        scene.cameras.append(camera)
        
        scene.lights.append(sunLight)
        
        let terrain = Terrain(heightMapName: "cliffs-of-insanity")
        terrain.height = 3
        scene.terrains = [terrain]
        
        self.renderer = TerrainRenderer(metalView: self.mtkView, scene: scene)
        
        let tapGesutre = NSClickGestureRecognizer(target: self, action: #selector(click))
        self.view.addGestureRecognizer(tapGesutre)
    }
    
    @objc func click() {
        scene.terrains.forEach{
            $0.isWireframe.toggle()
        }
    }
    
    override func scrollWheel(with event: NSEvent) {
        let delta = event.deltaY
        scene.sceneZooming(delta)
    }
    
    override func gesturePan(_ translation: float2) {
        scene.sceneRotate(translation)
    }

}
