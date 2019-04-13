//
//  AddLightViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/11.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class AddLightViewController: NSViewController {
    
    private var lightTypes = ["直射光", "环境光", "点光源", "舞台光"]
    
    @IBOutlet weak var selectLightTypeButton: NSPopUpButton!
    @IBOutlet weak var positionInputView: VectorInputView!
    @IBOutlet weak var lightColorWell: NSColorWell!
    @IBOutlet weak var specularColorWell: NSColorWell!
    @IBOutlet weak var attenuationXLabel: NSTextField!
    @IBOutlet weak var attenuationYLabel: NSTextField!
    @IBOutlet weak var attenuationZLabel: NSTextField!
    @IBOutlet weak var intensityLabel: NSTextField!
    @IBOutlet weak var coneDegreeLabel: NSTextField!

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
    var isVaild: Bool {
        return false
    }
}

