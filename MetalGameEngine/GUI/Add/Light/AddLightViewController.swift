//
//  AddLightViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/11.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class AddLightViewController: AddLightBaseViewController, EditableViewContoller {
    
    var isEdit: Bool = false
    
    private var lightTypes = ["直射光", "聚光灯光", "点光源", "环境光"]
    
    @IBOutlet weak var selectLightTypeButton: NSPopUpButton!
    @IBOutlet weak var positionInputView: VectorInputView!
    @IBOutlet weak var lightColorWell: NSColorWell!
    @IBOutlet weak var specularColorWell: NSColorWell!
    @IBOutlet weak var attenuationXLabel: NSTextField!
    @IBOutlet weak var attenuationYLabel: NSTextField!
    @IBOutlet weak var attenuationZLabel: NSTextField!
    @IBOutlet weak var intensityLabel: NSTextField!
    @IBOutlet weak var coneDegreeLabel: NSTextField!
    @IBOutlet weak var spotLightDirectionInputView: VectorInputView!
    
    @IBAction func sliderValueChanged(_ sender: NSSlider) {
        /*
         1: attenuation x
         2: attenuation y
         3: attenuation z
         4: intensity
         5: cone degree
         */
        let tag = sender.tag + 10
        if let label = self.view.viewWithTag(tag) as? NSTextField {
            label.stringValue = sender.stringValue
        }
    }
    
    @IBAction func selectLightTypeButtonClick(_ sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem - 1
        sender.title = lightTypes[index]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupItems()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        setupData()
    }
    
    private func setupItems() {
        selectLightTypeButton.removeAllItems()
        selectLightTypeButton.addItem(withTitle: "选择")
        selectLightTypeButton.addItems(withTitles: lightTypes)
    }
    
    private func setupData() {
        guard let light = self.light else { return }
        
        selectLightTypeButton.isEnabled = !isEdit
        selectLightTypeButton.title = lightTypes[Int(light.type.rawValue - 1)]
        
        positionInputView.float3Value = light.position
        
        spotLightDirectionInputView.float3Value = light.coneDirection
        
        lightColorWell.color = NSColor(deviceRed: CGFloat(light.color.x),
                                       green: CGFloat(light.color.y),
                                       blue: CGFloat(light.color.z),
                                       alpha: 1.0)
        
        specularColorWell.color = NSColor(deviceRed: CGFloat(light.specularColor.x),
                                          green: CGFloat(light.specularColor.y),
                                          blue: CGFloat(light.specularColor.z),
                                          alpha: 1.0)
        
        
        sliderWithTag(1).floatValue = light.attenuation.x
        sliderWithTag(2).floatValue = light.attenuation.y
        sliderWithTag(3).floatValue = light.attenuation.z
        sliderWithTag(4).floatValue = light.intensity
        sliderWithTag(5).floatValue = degrees(fromRadians: light.coneAngle)
        
        for i in 1...5 {
            sliderValueChanged(sliderWithTag(i))
        }
        
    }
    
    private func sliderWithTag(_ tag: Int) -> NSSlider {
        let slider = self.view.viewWithTag(tag) as! NSSlider
        return slider
    }
    
}


extension AddLightViewController: AddNodeVaildable {
    func checkVaild() -> (isVaild: Bool, errorMsg: String?) {
        
        let index = selectLightTypeButton.indexOfSelectedItem
        
        if !isEdit && index <= 0 {
            return (false, "灯光类型未选择")
        }
        
        var light = Light(0)
        light.position = positionInputView.float3Value
        light.color = lightColorWell.color.float3Value
        light.specularColor = specularColorWell.color.float3Value
        light.intensity = intensityLabel.floatValue
        light.attenuation = [attenuationXLabel.floatValue, attenuationYLabel.floatValue, attenuationZLabel.floatValue]
        light.coneAngle = radians(fromDegrees: coneDegreeLabel.floatValue)
        light.coneDirection = spotLightDirectionInputView.float3Value
        light.coneAttenuation = 12
        
        if let _light = self.light {
            light.type = _light.type
            light.id = _light.id
        } else {
            light.type = LightType(UInt32(index))
        }
        
        light.isAreaLight = 0
        self.light = light
        
        return (true, nil)
    }
}

