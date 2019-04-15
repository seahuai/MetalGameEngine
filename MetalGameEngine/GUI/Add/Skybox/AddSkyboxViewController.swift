//
//  AddSkyboxViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/11.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class AddSkyboxViewController: NSViewController {
    
    private var isCustom = false
    
    var skybox: Skybox!
    
    @IBOutlet weak var loadTextureButton: NSButton!
    @IBOutlet weak var customTextureButton: NSButton!
    @IBOutlet weak var textureNameTextfield: NSTextField!
    
    @IBOutlet weak var warningLabel: NSTextField!
    @IBOutlet weak var turbidityLabel: NSTextField!
    @IBOutlet weak var sunElevationLabel: NSTextField!
    @IBOutlet weak var upperAtmosphereScatteringLabel: NSTextField!
    @IBOutlet weak var groundAlbedoLabel: NSTextField!
    
    @IBAction func buttonClick(_ sender: NSButton) {
        isCustom = (sender != loadTextureButton)
        
        warningLabel.isHidden = isCustom
        textureNameTextfield.isEnabled = !isCustom
        setupSliderEnabled(isCustom)
        
        loadTextureButton.state = .off
        customTextureButton.state = .off
        sender.state = .on
    }
    
    @IBAction func sliderValueChanged(_ sender: NSSlider) {
        let tag = sender.tag + 10
        guard let label = self.view.viewWithTag(tag) as? NSTextField else { return }
        
        let number = NSNumber(value: sender.doubleValue)
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.format = "0.00"
        formatter.roundingMode = .halfUp
        guard let roundedString = formatter.string(from: number) else { return }
      
        label.stringValue = roundedString
    }
    
    private func setupSliderEnabled(_ enabled: Bool) {
        let tags = [1, 2, 3, 4]
        tags.forEach { (tag) in
            if let slider = self.view.viewWithTag(tag) as? NSSlider {
                slider.isEnabled = enabled
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonClick(loadTextureButton)
    }
    
}

extension AddSkyboxViewController: AddNodeVaildable {
    func checkVaild() -> (isVaild: Bool, errorMsg: String?) {
        
        var skybox: Skybox?
        
        if isCustom {
            skybox = Skybox(textureName: nil)
            var setting = Skybox.Setting()
            setting.turbidity = turbidityLabel.floatValue
            setting.groundAlbedo = groundAlbedoLabel.floatValue
            setting.upperAtmosphereScattering = upperAtmosphereScatteringLabel.floatValue
            setting.groundAlbedo = groundAlbedoLabel.floatValue
            skybox?.setting = setting
        } else {
            let textureName = textureNameTextfield.stringValue
            if textureName.isEmpty {
                warningLabel.stringValue = "资源名不能为空"
                return (false, nil)
            }
            skybox = Skybox(textureName: textureName)
            if skybox?.texture == nil {
                warningLabel.stringValue = "资源 \(textureName) 不存在"
                return (false, nil)
            }
        }
        
        if let skybox = skybox {
            self.skybox = skybox
            return (true, nil)
        }
        
        return (false, "创建天空盒失败")
    }
}

