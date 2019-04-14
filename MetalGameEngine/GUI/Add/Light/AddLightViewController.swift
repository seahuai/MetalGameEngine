//
//  AddLightViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/11.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class AddLightViewController: NSViewController {
    
    var lightNode: LightNode!
    
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
    
    private func setupItems() {
        selectLightTypeButton.removeAllItems()
        selectLightTypeButton.addItem(withTitle: "选择")
        selectLightTypeButton.addItems(withTitles: lightTypes)
    }
    
}


extension AddLightViewController: AddNodeVaildable {
    func checkVaild() -> (isVaild: Bool, errorMsg: String?) {
        
        let index = selectLightTypeButton.indexOfSelectedItem
        
        if index <= 0 {
            return (false, "灯光类型未选择")
        }
        
        lightNode = LightNode()
        lightNode.position = positionInputView.float3Value
        lightNode.color = lightColorWell.color.float3Value
        lightNode.specularColor = specularColorWell.color.float3Value
        lightNode.intensity = intensityLabel.floatValue
        lightNode.attenuation = [attenuationXLabel.floatValue, attenuationYLabel.floatValue, attenuationZLabel.floatValue]
        lightNode.coneAngle = radians(fromDegrees: coneDegreeLabel.floatValue)
        lightNode.coneDirection = spotLightDirectionInputView.float3Value
        lightNode.coneAttenuation = 12
        lightNode.type = LightType(UInt32(index))
        
        return (true, nil)
    }
}

