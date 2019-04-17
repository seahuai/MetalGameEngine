//
//  CustomSkyboxViewController.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/25.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class CustomSkyboxViewController: NormalMetalViewController {
    
    let scene = Scene()
    
    var skybox: Skybox?
    
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
//        scene.add(node: train)
//        scene.add(node: tree)
        
        let camera = Camera()
        camera.position = [0, 0, -4]
        camera.rotation = [-0.1, 0, 0]
        scene.cameras.append(camera)
        
        scene.lights.append(ambientLight)
        scene.lights.append(sunLight)
        
        skybox = Skybox()
        scene.skybox = skybox
        
        self.renderer = PhongRenderer(metalView: self.mtkView, scene: scene)
        
        setupSubViews(true)
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
    
        viewChangeSize(view: self.view)
    }
    
    override func viewChangeSize(view: NSView) {
        super.viewChangeSize(view: view)
        self.mtkView.frame.size.height -= 70
        self.mtkView.frame.origin.y = 70
        setupSubViews(false)
    }
    
    override func scrollWheel(with event: NSEvent) {
        let delta = event.deltaY
        scene.sceneZooming(delta)
    }
    
    override func gesturePan(_ translation: float2) {
        scene.sceneRotate(translation)
    }
}

extension CustomSkyboxViewController {
    
    private func setupSubViews(_ firstTime: Bool) {
        
        let width = 200
        
        let turbidityLabel = NSTextField()
        turbidityLabel.isEditable = false
        turbidityLabel.stringValue = "浑浊度 (0 to 1)"
        turbidityLabel.frame = NSRect(x: 0, y: 20, width: width, height: 44)
        
        let turbiditySlider = NSSlider(value: 0, minValue: 0, maxValue: 1, target: self, action: #selector(turbiditySliderChanged(sender:)))
        turbiditySlider.doubleValue = 0.28
        turbiditySlider.isContinuous = false
        turbiditySlider.frame = NSRect(x: 0, y: 10, width: width, height: 44)
        
        let sunElevationLabel = NSTextField()
        sunElevationLabel.isEditable = false
        sunElevationLabel.stringValue = "太阳高度角 (0 to 1)"
        sunElevationLabel.frame = NSRect(x: width, y: 20, width: width, height: 44)
        
        let sunElevationSlider = NSSlider(value: 0, minValue: 0, maxValue: 1, target: self, action: #selector(sunElevationSliderChanged(sender:)))
        sunElevationSlider.doubleValue = 0.6
        sunElevationSlider.isContinuous = false
        sunElevationSlider.frame = NSRect(x: width, y: 10, width: width, height: 44)
        
        let scatteringLabel = NSTextField()
        scatteringLabel.isEditable = false
        scatteringLabel.stringValue = "大气散射 (0 to 1)"
        scatteringLabel.frame = NSRect(x: width * 2, y: 20, width: width, height: 44)
        
        let scatteringSlider = NSSlider(value: 0, minValue: 0, maxValue: 1, target: self, action: #selector(scatteringSliderChanged(sender:)))
        scatteringSlider.doubleValue = 0.1
        scatteringSlider.isContinuous = false
        scatteringSlider.frame = NSRect(x: width * 2, y: 10, width: width, height: 44)
        
        let albedoLabel = NSTextField()
        albedoLabel.isEditable = false
        albedoLabel.stringValue = "地面反射 (0 to 10)"
        albedoLabel.frame = NSRect(x: width * 3, y: 20, width: width, height: 44)
        
        let albedoSlider = NSSlider(value: 0, minValue: 0, maxValue: 10, target: self, action: #selector(albedoSliderChanged(sender:)))
        albedoSlider.doubleValue = 4
        albedoSlider.isContinuous = false
        albedoSlider.frame = NSRect(x: width * 3, y: 10, width: width, height: 44)
        
        if firstTime {
            self.view.addSubview(turbidityLabel)
            self.view.addSubview(turbiditySlider)
            self.view.addSubview(sunElevationLabel)
            self.view.addSubview(sunElevationSlider)
            self.view.addSubview(scatteringLabel)
            self.view.addSubview(scatteringSlider)
            self.view.addSubview(albedoLabel)
            self.view.addSubview(albedoSlider)
        }
    }
    
    @objc public func turbiditySliderChanged(sender: NSSlider) {
        skybox?.setting?.turbidity = sender.floatValue
    }
    
    @objc public func sunElevationSliderChanged(sender: NSSlider) {
        skybox?.setting?.sunElevation = sender.floatValue
    }
    
    @objc public func scatteringSliderChanged(sender: NSSlider) {
        skybox?.setting?.upperAtmosphereScattering = sender.floatValue
    }
    
    @objc public func albedoSliderChanged(sender: NSSlider) {
        skybox?.setting?.groundAlbedo = sender.floatValue
    }
  
}

